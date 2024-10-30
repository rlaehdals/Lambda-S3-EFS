resource "aws_efs_file_system" "efs" {
  throughput_mode = "elastic"

  tags = {
    Name = "lambda-test"
  }

}

resource "aws_efs_access_point" "lambda-test" {
  file_system_id = aws_efs_file_system.efs.id

  root_directory {
    path = "/mnt/test"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
  }

  posix_user {
    gid            = 0
    secondary_gids = []
    uid            = 0
  }

}

resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.subnet_ids[0]
  security_groups = [var.security_groups]
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "test-1"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.account_id]
    }

    actions = [
      "elasticfilesystem:ClientRootAccess",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientMount"
    ]

    resources = [aws_efs_file_system.efs.arn]
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy         = data.aws_iam_policy_document.policy.json
}