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

# Get the current AWS account details
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# Create ECR repository
resource "aws_ecr_repository" "blog_terraform_docker" {
  name = "blog-terraform-docker"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "blog-terraform-docker"
  }
}

# Keep only one untagged image that precedes the latest image
resource "aws_ecr_lifecycle_policy" "blog_terraform_docker" {
  repository = aws_ecr_repository.blog_terraform_docker.name

  policy = <<EOF
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Keep only one untagged image that precedes the latest image",
                "selection": {
                    "tagStatus": "untagged",
                    "countType": "imageCountMoreThan",
                    "countNumber": 1
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
    EOF
}

# Build Docker image and push to ECR repository
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html
resource "terraform_data" "docker_build" {
  depends_on = [aws_ecr_repository.blog_terraform_docker]

  # To make sure the local-exec provisioner runs every time
  triggers_replace = [timestamp()]

  provisioner "local-exec" {
    command = <<EOF
        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
        # https://stackoverflow.com/a/68004485
        docker build --platform linux/amd64 -t "${aws_ecr_repository.blog_terraform_docker.repository_url}:latest" .
        docker push "${aws_ecr_repository.blog_terraform_docker.repository_url}:latest"
    EOF
  }
}
