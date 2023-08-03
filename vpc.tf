resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Development-VPC"
    Env  = "Dev"
  }
}

data "aws_availability_zones" "azs" {
}

locals {
  azs = data.aws_availability_zones.azs.names
}

resource "aws_subnet" "lb" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.lb-cidr[count.index]
  availability_zone = local.azs[count.index]
  count             = length(var.lb-cidr)
  tags = {
    Name = "Load Balancer Tier Public Subnet ${count.index + 1}"
    Env  = "Dev"
  }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.app-cidr[count.index]
  availability_zone = local.azs[count.index]
  count             = length(var.app-cidr)
  tags = {
    Name = "App Subnet ${count.index + 1}"
  }
}
