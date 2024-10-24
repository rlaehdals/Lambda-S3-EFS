output "bucket_arn" {
  value = aws_s3_bucket.lambda-efs-s3-test.arn
}

output "bucket_id" {
  value = aws_s3_bucket.lambda-efs-s3-test.id
}