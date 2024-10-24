variable "account_id" {}
variable "region" {}
variable "bucket_arn" {}
variable "private_subnets_ids" {}
variable "lambda_security_group_ids" {}
variable "efs_access_point_arn" {
  default = null
}