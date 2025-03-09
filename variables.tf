variable "aws_region_use1" {
  description = "Primary AWS region (us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "aws_region_use2" {
  description = "Secondary AWS region (us-east-2)"
  type        = string
  default     = "us-east-2"
}

variable "ami_id_use1" {
  description = "AMI ID for Ubuntu 20.04 in us-east-1"
  type        = string
  default     = "ami-04b4f1a9cf54c11d0"
}

variable "ami_id_use2" {
  description = "AMI ID for Ubuntu 20.04 in us-east-2"
  type        = string
  default     = "ami-0cb91c7de36eed2cb"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
