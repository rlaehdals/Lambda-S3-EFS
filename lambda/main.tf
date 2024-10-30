module "lambda_s3" {
  source = "./common"

  lambda_name   = "lambda_s3"
  variables     = {}
  architectures = ["arm64"]
  memory_size   = 3008

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/lambda-s3:latest"

  common_lambda_policy = data.aws_iam_policy_document.lambda_s3_policy.json

  vpc_config = {
    subnet_ids         = var.private_subnets_ids
    security_group_ids = var.lambda_security_group_ids
  }

  storage = 10240
}

module "lambda_efs" {
  source = "./common"

  lambda_name   = "lambda_efs"
  variables     = {}
  architectures = ["arm64"]

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/lambda-efs:latest"

  vpc_config = {
    subnet_ids         = var.private_subnets_ids
    security_group_ids = var.lambda_security_group_ids
  }

  file_system_config = {
    arn              = var.efs_access_point_arn
    local_mount_path = "/mnt/test"
  }

  common_lambda_policy = data.aws_iam_policy_document.lambda_efs_policy.json
}

data "aws_iam_policy_document" "lambda_efs_policy" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:elasticfilesystem:ap-northeast-2:${var.account_id}:file-system/*",
    "arn:aws:elasticfilesystem:ap-northeast-2:${var.account_id}:access-point/*"]
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:DescribeAccessPoints"
    ]
  }
}

data "aws_iam_policy_document" "lambda_s3_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "${var.bucket_arn}/*",
      var.bucket_arn
    ]
    effect = "Allow"
  }
}

