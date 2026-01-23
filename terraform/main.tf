terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source             = "./modules/ec2"
  ami_id             = var.ami_id
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_id
  instance_profile   = module.iam.instance_profile_name
  aws_region         = var.aws_region
  ecr_registry       = var.ecr_registry
  frontend_image_tag = var.frontend_image_tag
  backend_image_tag  = var.backend_image_tag
  backend_env        = var.backend_env
  frontend_repo      = var.frontend_repo_name
  backend_repo       = var.backend_repo_name
  key_name           = var.key_name
}
