output "efs_access_point_arn" {
  value = aws_efs_access_point.lambda-test.arn
}

output "efs_dns_name" {
  value = aws_efs_file_system.efs.dns_name
}