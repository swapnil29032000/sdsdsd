# 🎯 Production-Ready Setup Guide

This guide is designed for any developer to get the **Nexgensis DevOps Assessment** stack running in under 2 minutes, without needing to ask a single question.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: Usually included with Docker Desktop.
- **Git**: To clone the repository.

---

## � Quick Start (Automated)

We have provided a unified orchestration setup that configures networking, dependencies, and environment variables automatically.

### 1. Zero-Config Environment Setup
The applications require specific environment variables to communicate. Copy the templates provided:

```bash
# From the project root
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env
```

### 2. Launch the Stack
Run the following command to build the images and start the services in detached mode:

```bash
docker compose up -d --build
```

*Note: The `--build` flag ensures any recent code changes are reflected in the new images.*

### 3. Verify Health
Check if the containers are running:

```bash
docker compose ps
```

You should see `nexgensis-frontend` and `nexgensis-backend` with a status of `Up`.

---

## 🌐 Application Access

| Component | URL | Description |
| :--- | :--- | :--- |
| **Frontend UI** | [http://localhost:5173](http://localhost:5173) | The main React dashboard. |
| **Backend API** | [http://localhost:8000/api/hello/](http://localhost:8000/api/hello/) | The Django API endpoint. |

---

## 🛠 Troubleshooting & FAQs

### "Frontend says Connection Failed"
- **Reason**: The frontend is trying to reach the API at `localhost:8000`. Ensure the backend container is up.
- **Fix**: Run `docker compose logs backend` to check for Django startup errors (e.g., database migrations).

### "I changed the code but the UI didn't update"
- **Reason**: Since we use multi-stage production builds, the code is "baked" into the image.
- **Fix**: Re-run the launch command with the `--build` flag: `docker compose up -d --build`.

### "How do I see the logs?"
- To see live logs: `docker compose logs -f`
- To see specific service logs: `docker compose logs -f frontend`

---

## � Deep Dive Documentation

For a better understanding of the project's evolution and technical choices:
- 📖 **[Deployment Journey (Deployment.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/Deployment.md)**: Every technical "Why" and "How" with code snippets.
- 🚧 **[Challenges Log (CHALLENGES.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/CHALLENGES.md)**: Problems encountered during deployment and how they were solved.
- 🚀 **[CI/CD Pipeline (CICD.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/CICD.md)**: Advanced GitHub Actions workflows for AWS ECR deployments.

---

## ⚙️ Architecture Summary
- **Backend**: Django 6.0 + Gunicorn (Non-root user).
- **Frontend**: React + Vite + Serve (Non-root user, multi-stage optimized).
- **Deployment**: Secure AWS OIDC authentication (Follow [OIDC Setup Instructions](file:///home/rohit/Rohit/Nexgensis-devops-assessment/CICD.md#%EF%B8%8F-aws-oidc-setup-identity-provider)).
- **Network**: Isolated Docker bridge network where `frontend` connects to `backend`.
- **CI/CD**: Automates Docker builds and ECR pushes with **automated repository creation** and **secure frontend build-time secret injection**. Backend secrets are managed at runtime.

---
*Maintained by Antigravity AI for Nexgensis.*
