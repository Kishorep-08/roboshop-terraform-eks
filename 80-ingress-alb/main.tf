# Bakcend alb facing frontend (accepts traffic from frontend)
resource "aws_lb" "ingress_alb" {
  name               = "${local.common_name}-ingress-alb" # roboshop-dev-ingress-alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.ingress_alb_sg_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = true

  tags = merge(
    local.common_tags,
    {
        Name = "${local.common_name}-ingress-alb"
    }
  )
}

# ingress load balancer listening on port 443
resource "aws_lb_listener" "ingress" {
  load_balancer_arn = aws_lb.ingress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06" 
  certificate_arn   = "${local.certificate_arn}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hi, I am from ingress alb"
      status_code  = "200"
    }
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${local.common_name}-frontend"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = local.vpc_id
  deregistration_delay = 60 # waiting period before deleting the instance

  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/"
    port = 8080
    protocol = "HTTP"
    timeout = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.ingress.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.frontend.arn}"
  }

  condition {
    host_header {
      values = ["${var.environment}.${var.domain_name}"]
    }
  }
}



resource "aws_lb_listener_certificate" "roboshop" {
  listener_arn    = aws_lb_listener.ingress.arn
  certificate_arn = local.certificate_arn
}

# Route53 record for ingress alb
resource "aws_route53_record" "ingress_alb" {
  zone_id = local.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.ingress_alb.dns_name
    zone_id                = aws_lb.ingress_alb.zone_id
    evaluate_target_health = true
  }
}

