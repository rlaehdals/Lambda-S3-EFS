module "lambda-s3" {
  source         = "./common"
  ecr_image_name = "lambda-s3"
}

module "lambda-efs" {
  source         = "./common"
  ecr_image_name = "lambda-efs"
}