module "vpc" {
  source = "./vpc"

  vpc_cidr  = "10.0.0.0/16"
  sub_count = 1
  region = "ap-northeast-2"
}

module "sg" {
  source = "./sg"

  vpc_id = module.vpc.vpc_id
}

module "efs" {
  source = "./efs"

  account_id = "" # account id 넣기
  security_groups = module.sg.efs_sg
  subnet_ids = module.vpc.private_subnets_id
}

module "lambda" {
  source = "./lambda"

  account_id    = "" # account id 넣기
  region        = "ap-northeast-2"
  bucket_arn    = module.s3.bucket_arn
  lambda_security_group_ids = [module.sg.efs_sg]
  private_subnets_ids = module.vpc.private_subnets_id
  efs_access_point_arn = module.efs.efs_access_point_arn
}

module "s3" {
  source = "./s3"

  bucket_name = "lambda-efs-s3-test"
}

module "ecr" {
  source = "./ecr"
}