variable "ami_id" {
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_id" {
  description = "Subnet ID"
}

variable "instance_profile" {
  description = "IAM instance profile name"
}

variable "aws_region" {
  description = "AWS region"
}

variable "ecr_registry" {
  description = "ECR Registry URL"
}

variable "frontend_image_tag" {
  description = "Frontend image tag"
}

variable "backend_image_tag" {
  description = "Backend image tag"
}

variable "backend_env" {
  description = "Backend environment variables"
}

variable "frontend_repo" {
  description = "Frontend repository name"
}

variable "backend_repo" {
  description = "Backend repository name"
}

variable "key_name" {
  description = "SSH key pair name"
}
