
terraform {
  required_version = "~>1.1"

  backend "s3" {
    bucket         = "kojitech.3.tier.arch.jnj" # 
    dynamodb_table = "terraform-state-block"    # 
    region         = "us-east-1"
    key            = "path/env/kojitechs-3-tier"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  vpc_id             = module.vpc.vpc_id
  pub_subnet_id      = module.vpc.pub_subnetid
  private_subnet_id  = module.vpc.private_subnetid
  database_subnet_id = module.vpc.database_subnetid
}

module "vpc" {
  source = "git::https://github.com/Charles123Bob-Duru/kojitechs-vpc-module.git?ref=v1.1.0"

  vpc_tags = {
    Name = "Kojitechs_vpc_${terraform.workspace}"
  }
  vpc_cidr      = var.vpc_cidr
  public_cidr   = var.public_cidr
  private_cidr  = var.private_cidr
  database_cidr = var.database_cidr
}
