
# Data block to figure out the avaialble AZs, local block to create an alias

data "aws_availability_zones" "azs" {
}

locals {
  azs = data.aws_availability_zones.azs.names
}

# To Create VPC

resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Development-VPC"
    Env  = "Dev"
  }
}

# Creating Public Subnets for Load Balancers 

resource "aws_subnet" "lb" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = cidrsubnet(var.vpc-cidr, 8, count.index)
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true
  count             = length(local.azs)
  tags = {
    Name = "Load Balancer Tier Public Subnet ${count.index + 1}"
    Env  = "Dev"
  }
}

# Creating Private Subnets for App tier 

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = cidrsubnet(var.vpc-cidr, 8, length(local.azs) + count.index)
  availability_zone = local.azs[count.index]
  count             = length(local.azs)
  tags = {
    Name = "App Subnet ${count.index + 1}"
  }
}


