# 🐳 Docker-Based DevOps Deployment (with Terraform & CI/CD)

## 📌 Overview
This document describes the **Docker-based deployment strategy** for a full-stack application, enhanced with **CI/CD automation using GitHub Actions** and **Infrastructure as Code (IaC) using Terraform**.

The focus of this setup includes:
- Containerization using Docker  
- Service orchestration using Docker Compose  
- Automated image build and push using GitHub Actions  
- Cloud infrastructure provisioning using Terraform  

---

## 🧩 Application Stack

- **Backend:** Django (REST API)
- **Frontend:** React (Vite + TypeScript)
- **Containerization:** Docker
- **Orchestration:** Docker Compose
- **CI/CD:** GitHub Actions
- **Infrastructure as Code:** Terraform
- **Cloud Platform:** AWS

---

## 🛠 Docker Containerization

### Backend (Django)
- Dockerized using a **Python slim base image**
- Dependencies installed using `requirements.txt`
- REST API exposed on **port 8000**
- Runs as a standalone Docker container

### Frontend (React – Vite + TypeScript)
- Dockerized using a **Node Alpine base image**
- Application built using **npm**
- Frontend exposed on **port 3000**
- Served through a Docker container

---

## 🔗 Docker Compose Orchestration

- `docker-compose.yml` is used to manage multi-container deployment
- Backend and frontend run as **separate services**
- Services communicate via an **internal Docker network**
- Ports are mapped to the host system for browser access

### Port Mapping

| Service  | Container Port | Host Port |
|--------|----------------|-----------|
| Backend | 8000 | 8000 |
| Frontend | 3000 | 3000 |

---

## ▶️ Run Application Using Docker

### Prerequisites
- Docker
- Docker Compose

### Command
```bash
docker compose up --build
```
## ☁️ Terraform (Infrastructure as Code)

Terraform is used alongside Docker to provision and manage cloud infrastructure required for deployment.

### Terraform Integration with Docker Workflow
- Terraform code is stored in `infra-terraform/`
- Infrastructure is defined using `.tf` files
- Enables automated provisioning of cloud resources (e.g., EC2, networking)
- Ensures Docker containers run on consistent and reproducible infrastructure

### Terraform Commands
```bash
terraform init
terraform validate
terraform plan
terraform apply
```
