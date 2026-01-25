variable "aws_region"{
    description = "this is the region for aws region"
    default = "eu-west-1"
}

# variable "aws_ec2_ami_id"{
#     description ="this is ami_id for ubuntu instance"
#     default = "ami-087a0156cb826e921"

# }

variable "aws_instance_type" {
    description ="this is a instance type for ec2 instance"
    default = "t2.micro"
  
}

variable "aws_ec2_instance_name" {
    description = "this  is the name given to the ec2 instance"
    default = "priya_instance"
  
}

variable "aws_root_volume_size" {
    description ="this is root volume size for the aws "
    default = "10"
  
}

variable "aws_instance_count"{
    description = "The count if Ec2 instance needed"
    default = 1
}