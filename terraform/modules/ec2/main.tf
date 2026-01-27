resource "aws_security_group" "nexgensis_sg" {
  count       = var.create_security_group ? 1 : 0
  name        = var.security_group_name
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

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.create_security_group ? aws_security_group.nexgensis_sg[0].id : var.existing_security_group_id]
  iam_instance_profile   = var.instance_profile
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Function to wait for apt locks (with Nuke logic)
              wait_for_apt() {
                echo "Checking for system locks..."
                local timeout=60
                while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
                  if [ "$timeout" -le 0 ]; then
                    echo "Lock persists, implementing aggressive resolution..."
                    sudo killall -9 apt apt-get 2>/dev/null || true
                    sudo rm -f /var/lib/apt/lists/lock /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock
                    sudo dpkg --configure -a
                    break
                  fi
                  echo "Waiting for system to release lock... ($timeout)"
                  sleep 5
                  ((timeout--))
                done
              }

              wait_for_apt
              apt-get update
              
              wait_for_apt
              apt-get install -y docker.io docker-compose-v2 unzip
              
              # Idempotent Official AWS CLI v2 Installation
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip -o awscliv2.zip
              ./aws/install --update
              
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "Nexgensis-App-Server"
  }
}
