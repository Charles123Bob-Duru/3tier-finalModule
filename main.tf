
terraform {
  required_version = ">=1.1"

  backend "s3" {
    bucket         = "kojitechs.aws.eks.with.terraform.tf"
    dynamodb_table = "terraform-lock"
    region         = "us-east-1"
    key            = "path/env/3-tier"
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
  region = "us-east-1"
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

# aws_internet_gateway.gw.id

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

# creating pulic route table 
resource "aws_route_table" "public_route_table" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# CREATING A ROUTE TABLE ASSOCIATION FOR PULIC SUBNET 
resource "aws_route_table_association" "public_association" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# creating deafult route table
resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.kojitechs_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id 
  }
}


# CREATING A NATWAY
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id # it wouldn't make sense to have a dynamic address on a NAT device
  subnet_id     = aws_subnet.public_subnet[0].id # pulic subnet!! 

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}

# EIP
resource "aws_eip" "eip" {
  
  vpc      = true
  depends_on = [aws_internet_gateway.gw]
}