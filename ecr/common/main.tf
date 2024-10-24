resource "aws_ecr_repository" "ecr_repo" {
  name = var.ecr_image_name

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    create_before_destroy = true
  }
}