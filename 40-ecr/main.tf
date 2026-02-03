resource "aws_ecr_repository" "component" {
  for_each = toset(var.component)
  name                 = "${var.project_name}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}