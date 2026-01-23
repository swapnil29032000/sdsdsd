resource "aws_security_group" "nexgensis_sg" {
  name_prefix = "nexgensis-sg-"
  description = "Allow HTTP, HTTPS and SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.nexgensis_sg.id]
  iam_instance_profile   = var.instance_profile
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install Docker
              apt-get update
              apt-get install -y docker.io docker-compose-v2 awscli
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "Nexgensis-App-Server"
  }
}
