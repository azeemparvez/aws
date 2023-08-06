
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
    Env  = "Dev"
  }
}

# Creating an Internet Gateway, Route Table, Route and Associate to LB Subnets 

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id
  tags = {
    Name = "Dev-IGW"
    Env = "Dev"
  }
}

resource "aws_route_table" "igw-rt" {
  vpc_id = aws_vpc.dev-vpc.id
  tags = {
    Name = "RT for IGW"
    Env = "Dev"
  }
}

resource "aws_route" "public-route" {
  route_table_id = aws_route_table.igw-rt.id
  destination_cidr_block = var.internet
  gateway_id = aws_internet_gateway.dev-igw.id

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.lb[count.index].id
  route_table_id = aws_route_table.igw-rt.id
  count = length(local.azs)
}

/*
# Creating a NAT Gateway 

resource "aws_eip" "nat-ip" { 
}

resource "aws_nat_gateway" "nat-gw" {
   allocation_id = aws_eip.nat-ip.id
   subnet_id = aws_subnet.lb[0].id
   tags = {
     Name = "NAT-GW for Dev VPC"
     Env = "Dev"
   }
}

resource "aws_default_route_table" "nat-rt" {
  default_route_table_id = aws_vpc.dev-vpc.default_route_table_id
  tags = {
    Name = "NAT-RT for Dev"
  }
}

resource "aws_route" "nat-route" {
  route_table_id = aws_default_route_table.nat-rt.id
  gateway_id = aws_nat_gateway.nat-gw.id
  destination_cidr_block = var.internet
}

resource "aws_route_table_association" "nat-rt-a" {
  subnet_id = aws_subnet.app[count.index].id
  route_table_id = aws_default_route_table.nat-rt.id
  count = length(local.azs)
}
*/

resource "aws_security_group" "web-app" {
  vpc_id = aws_vpc.dev-vpc.id
  name = "allow_http"
  description = "Allow http inbound traffic"
  ingress {
    description = "http from VPC"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ var.internet ]
  }
    ingress {
    description = "http from VPC"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ var.internet ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.internet]
  }
  
  tags = {
    Name = "allow-http"
  }
  
}