variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "ecr_registry" {
  description = "ECR Registry URL"
  type        = string
}

variable "frontend_image_tag" {
  description = "Tag of the frontend image to deploy"
  default     = "prod-latest"
}

variable "backend_image_tag" {
  description = "Tag of the backend image to deploy"
  default     = "prod-latest"
}

variable "backend_env" {
  description = "Contents of the .env file for the backend"
  type        = string
  default     = ""
  sensitive   = true
}

variable "frontend_repo_name" {
  description = "Frontend repository name"
  default     = "nexgensis/nexgensis-frontend"
}

variable "backend_repo_name" {
  description = "Backend repository name"
  default     = "nexgensis/nexgensis-backend"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  default     = "ami-00bb6a80f01f03502" # Ubuntu 24.04 ap-south-1
}

variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access"
  type        = string
  default     = "my-aws"
}
