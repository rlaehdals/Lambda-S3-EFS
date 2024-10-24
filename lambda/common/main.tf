locals {
  commons = {
    "common" = "common"
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_name
  architectures = var.architectures

  memory_size  = var.memory_size
  package_type = "Image"
  image_uri    = var.image_uri
  timeout      = var.timeout

  environment {
    variables = merge(var.variables, local.commons)
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_config == null ? [] : [var.file_system_config]
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  ephemeral_storage {
    size = var.storage
  }

  role = aws_iam_role.iam_for_lambda.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.lambda_name}_assume_role"
  assume_role_policy = data.aws_iam_policy_document.iam_for_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_iam" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.lambda_name}_policy"
  policy = data.aws_iam_policy_document.common_lambda_policy.json
}

data "aws_iam_policy_document" "common_lambda_policy" {
  override_policy_documents = [var.common_lambda_policy]
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]
  }
  statement {
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}


data "aws_iam_policy_document" "iam_for_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}
