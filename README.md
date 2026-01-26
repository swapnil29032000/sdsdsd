- # DevOps Assessment – Nexgensis

## Overview
This project demonstrates Docker-based deployment of a frontend and backend application on AWS EC2.

## Tech Stack
- Frontend: React + Vite + Nginx
- Backend: Django REST Framework
- Containerization: Docker
- Orchestration: Docker Compose
- Cloud Platform: AWS EC2 (Ubuntu)

## Application Ports
- Frontend: 3000
- Backend: 8000

## Run Locally
docker-compose up --build

## AWS Deployment
- EC2 instance with Docker and Docker Compose installed
- Security groups allow ports 3000 and 8000
- Containers managed using Docker Compose

## Backend Routing
- API endpoints available under `/api`
- Root URL intentionally returns 404 (API-only service)

## Status
Frontend and backend containers are running successfully on AWS EC2.

