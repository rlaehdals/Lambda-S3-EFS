resource "aws_s3_bucket" "lambda-efs-s3-test" {
  bucket = var.bucket_name
}
