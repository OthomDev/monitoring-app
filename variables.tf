
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 20.04"
  type        = string
  default     = "ami-04b4f1a9cf54c11d0"  # Update based on your region
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}
