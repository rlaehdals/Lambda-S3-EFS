output "lambda_s3_arn" {
  value = module.lambda_s3.lambda_arn
}

output "lambda_efs_arn" {
  value = module.lambda_efs.lambda_arn
}
