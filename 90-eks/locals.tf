locals {

    common_name = "${var.project_name}-${var.environment}"
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
    common_tags = {
        Project = var.project_name
        Environment = var.environment
    }
    zone_id = data.aws_route53_zone.hosted_zone_id.zone_id
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    eks_node_sg_id = data.aws_ssm_parameter.eks_node_sg_id.value
    eks_control_plane_sg_id = data.aws_ssm_parameter.eks_control_plane_sg_id.value

    
}