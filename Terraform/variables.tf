variable "key_name" {
  description = "EC2 key pair name"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-0f58b397bc5c1f2e8" # Ubuntu 22.04 (us-east-1)
}
