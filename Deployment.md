# Deployment Journey

This document chronicles the dockerization process of the Nexgensis DevOps Assessment project, detailing the "Why" and "How" behind every major technical decision.

## [2026-01-23] Initial Dockerization

### 1. Backend Transformation

**Action**: Created a multi-stage `Dockerfile` and integrated `python-dotenv`.

**Why?**
- **Multi-Stage**: To separate the build environment from the runtime environment, reducing the final image size significantly.
- **Non-Root User**: Runs as a dedicated `django` user to prevent potential root access to the host.
- **Environment Variables**: Portable configuration via `python-dotenv`.

**Code Snippet (Dockerfile Stage 2)**:
```dockerfile
FROM python:3.12-slim
WORKDIR /app
RUN addgroup --system django && adduser --system --group django
COPY --from=builder /install /usr/local
USER django
```

---

### 2. Frontend Transformation

**Action**: Created a multi-stage `Dockerfile` using `node:22-slim` and `serve`.

**Why?**
- **Production Server (`serve`)**: Optimized for high-performance static file delivery and handles SPA routing natively.
- **Robust User Setup**: Used `useradd -m nodejs` and global `serve` installation to avoid runtime permission errors.

**Code Snippet (Production Serving)**:
```dockerfile
CMD ["serve", "-s", "dist", "-l", "5173"]
```

---

### 3. Orchestration with Docker Compose

**Action**: Defined `docker-compose.yml` for unified management.

---

### 4. Environment Management

**Action**: Added `.env.example` files for security and developer onboarding.

---

## [2026-01-23] CI/CD Integration

### **Action**: Implemented automated Docker builds and ECR pushes using GitHub Actions.

**Why?**
- **Environment Workflow**: Mapping branches (`main`, `DEV`, `QA`, `PREPROD`) to specific ECR tags (`prod-latest`, `dev-latest`, etc.).
- **OIDC Security**: Scalable AWS authentication without using static Access Keys.

---

## 🚀 Further Documentation
- 🚧 **[Challenges & Solutions (CHALLENGES.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/CHALLENGES.md)**: Deep dive into the hurdles overcome.
- 🚀 **[Quick Start Guide (README.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/README.md)**: Foolproof instructions for teammates.
- 🎡 **[CI/CD Setup (CICD.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/CICD.md)**: GitHub Actions and AWS ECR integration details.
