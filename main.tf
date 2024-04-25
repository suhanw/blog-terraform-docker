terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Get the current AWS account details
data "aws_caller_identity" "current" {}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

locals {
  account_id     = data.aws_caller_identity.current.account_id
  default_vpc_id = data.aws_vpc.default.id
  common_tags = {
    project = "blog-terraform-docker"
  }
}

# Create ECR repository
resource "aws_ecr_repository" "blog_terraform_docker" {
  name = "blog-terraform-docker"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
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
        aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

        # https://stackoverflow.com/a/68004485
        docker build --platform linux/amd64 -t "${aws_ecr_repository.blog_terraform_docker.repository_url}:latest" .
        docker push "${aws_ecr_repository.blog_terraform_docker.repository_url}:latest"
    EOF
  }
}

# IAM Role for the EC2 instance to allow it to pull images from ECR.
resource "aws_iam_role" "blog_terraform_docker_ec2_role" {
  name = "blog-terraform-docker-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })

  tags = local.common_tags
}

# Policy Attachment to allow EC2 instance to communicate with ECR.
resource "aws_iam_role_policy_attachment" "blog_terraform_docker_ec2_ecr_policy" {
  role = aws_iam_role.blog_terraform_docker_ec2_role.name
  # https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAmazonEC2ContainerRegistryReadOnly?section=permissions
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create an EC2 instance profile which will house the role.
resource "aws_iam_instance_profile" "blog_terraform_docker_ec2_instance_profile" {
  name = "blog-terraform-docker-ec2-instance-profile"
  role = aws_iam_role.blog_terraform_docker_ec2_role.name

  tags = local.common_tags
}

# Create a Security Group to allow SSH access to the instance.
module "dev_ssh_sg" {
  # https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  source = "terraform-aws-modules/security-group/aws"

  name        = "dev_ssh_sg"
  description = "Security group for SSH access"
  vpc_id      = local.default_vpc_id

  ingress_cidr_blocks = ["108.53.23.213/32", "38.122.226.210/32"]
  ingress_rules       = ["ssh-tcp"]

  tags = local.common_tags
}

# Create a Security Group to allow HTTP access to the instance.
module "ec2_sg" {
  # https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
  source = "terraform-aws-modules/security-group/aws"

  name        = "ec2_sg"
  description = "Security group for ec2_sg"
  vpc_id      = local.default_vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.common_tags
}

resource "aws_instance" "blog_terraform_docker_ec2_instance" {
  lifecycle {
    # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#replace_triggered_by
    replace_triggered_by = [terraform_data.docker_build.id]
  }

  # Amazon Linux 2023 AMI 2023.4.20240416.0 x86_64 HVM kernel-6.1
  # https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#ImageDetails:imageId=ami-04e5276ebb8451442
  ami           = "ami-04e5276ebb8451442"
  instance_type = "t3.micro"
  key_name      = "blog-terraform-docker" # https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#KeyPairs:
  vpc_security_group_ids = [
    module.ec2_sg.security_group_id,
    module.dev_ssh_sg.security_group_id
  ]
  iam_instance_profile = aws_iam_instance_profile.blog_terraform_docker_ec2_instance_profile.name

  # https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-docker.html
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker $(whoami)
    docker ps

    # https://github.com/awslabs/amazon-ecr-credential-helper?tab=readme-ov-file#amazon-linux-2023-al2023
    sudo dnf install -y amazon-ecr-credential-helper

    # https://github.com/awslabs/amazon-ecr-credential-helper?tab=readme-ov-file#docker
    # Check if ~/.docker/config.json exists
    if [ ! -f ~/.docker/config.json ]; then
      # If not, create the file
      mkdir -p ~/.docker
      touch ~/.docker/config.json
    fi
    # Update the file with the content { "credsStore": "ecr-login" }
    echo '{ "credsStore": "ecr-login" }' > ~/.docker/config.json

    # Pull the image from ECR and run a container with it.
    docker pull ${aws_ecr_repository.blog_terraform_docker.repository_url}:latest
    docker run -d -p 80:3000 ${aws_ecr_repository.blog_terraform_docker.repository_url}:latest

    # https://serverfault.com/questions/228481/where-is-log-output-from-cloud-init-stored
  EOF

  tags = local.common_tags
}

output "account_id" {
  value = local.account_id
}

output "public_ip" {
  value = aws_instance.blog_terraform_docker_ec2_instance.public_ip
}

output "public_dns" {
  value = aws_instance.blog_terraform_docker_ec2_instance.public_dns
}
