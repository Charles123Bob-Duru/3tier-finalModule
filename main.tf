
terraform {
  required_version = ">1.1"

  backend "s3" {
    bucket         = "kojitech.3.tier.arch.jnj"
    dynamodb_table = "terraform-state-block"
    region         = "us-east-1"
    key            = "path/env"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "Charles"
}

locals {
  vpc_id = aws_vpc.kojitechs_vpc.id
  azs    = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {
  state = "available"
}


# Creating vpc
resource "aws_vpc" "kojitechs_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "kojitechs_vpc"
  }
}

# Creating internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = local.vpc_id

  tags = {
    Name = "gw"
  }
}

#  Creating public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_cidr) # telling terraform calculate the size of public_cidr var

  vpc_id                  = local.vpc_id
  cidr_block              = var.public_cidr[count.index]
  availability_zone       = element(slice(local.azs, 0, 2), count.index) # 
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

# private subnet 
resource "aws_subnet" "private_subnet" {
  count = length(var.private_cidr) # telling terraform calculate the size of public_cidr var

  vpc_id            = local.vpc_id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = element(slice(local.azs, 0, 2), count.index) # 

  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

# database subnet
resource "aws_subnet" "datebase_subnet" {
  count = length(var.database_cidr) # telling terraform calculate the size of public_cidr var

  vpc_id            = local.vpc_id
  cidr_block        = var.database_cidr[count.index]
  availability_zone = element(slice(local.azs, 0, 2), count.index) # 

  tags = {
    Name = "database_subnet_${count.index + 1}"
  }
}

