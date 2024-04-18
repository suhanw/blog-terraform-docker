provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.7.5"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}
