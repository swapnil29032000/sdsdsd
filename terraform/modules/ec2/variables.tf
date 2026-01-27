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

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "nexgensis-sg"
}

variable "create_security_group" {
  description = "Whether to create a new security group or reuse an existing one"
  type        = bool
  default     = true
}

variable "existing_security_group_id" {
  description = "The ID of an existing security group to use if create_security_group is false"
  type        = string
  default     = ""
}
