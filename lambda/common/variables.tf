variable "lambda_name" {}
variable "image_uri" {}
variable "variables" {}
variable "common_lambda_policy" {}
variable "file_system_config" {
  default = null
}

variable "vpc_config" {
  default = null
}

variable "storage" {
  default = 512
}

variable "architectures" {
  default = ["x86_64"]
}
variable "memory_size" {
  default = 256
}
variable "timeout" {
  default = 900
}
variable "retention_days" {
  default = 14
}