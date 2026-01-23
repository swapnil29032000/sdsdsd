variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "192.168.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "192.168.1.0/24"
}

variable "aws_region" {
  description = "AWS region"
}
