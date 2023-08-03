terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-hipertest"
    key            = "config-folder"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  # Configuration options
}