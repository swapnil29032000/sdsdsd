data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "devops_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "assessment-cicd"   # Replace with your actual AWS key pair name

  security_groups = [aws_security_group.devops_sg.name]

  tags = {
    Name = "DevOps-Assessment"
  }
}
