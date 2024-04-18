terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# ECR 
resource "aws_ecr_repository" "blog-terraform-docker" {
  name = "blog-terraform-docker"

  tags = {
    project = "blog-terraform-docker"
  }
}
