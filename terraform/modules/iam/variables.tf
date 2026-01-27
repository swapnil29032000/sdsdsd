variable "create_role" {
  description = "Whether to create a new IAM role or reuse an existing one"
  type        = bool
  default     = true
}

variable "existing_role_name" {
  description = "The name of an existing IAM role to use if create_role is false"
  type        = string
  default     = "nexgensis-ec2-ecr-role"
}
