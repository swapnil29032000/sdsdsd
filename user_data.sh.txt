#!/bin/bash
apt update -y
apt install docker.io docker-compose git -y
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
