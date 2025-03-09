
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
  region = var.aws_region
}

resource "aws_key_pair" "flask_key" {
  key_name   = "new_key"  # Name of the key pair
  public_key = file("~/.ssh/my_new_terraform_key.pub") # Update this path if needed
}

resource "aws_instance" "flask_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.flask_key.key_name  # Use the Terraform-created key
  security_groups = [aws_security_group.flask_sg.name]
  user_data = file("${path.module}/userData.sh")

  tags = {
    Name = "MySmallFlaskApp"
  }
}

resource "aws_security_group" "flask_sg" {
  name        = "flask_sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
