# Deployment Journey

This document chronicles the dockerization process of the Nexgensis DevOps Assessment project, detailing the "Why" and "How" behind every major technical decision.

## [2026-01-23] Initial Dockerization

### 1. Backend Transformation

**Action**: Created a multi-stage `Dockerfile` and integrated `python-dotenv`.

**Why?**
- **Multi-Stage**: To separate the build environment (which needs `gcc` for some packages) from the runtime environment. This reduces the final image size significantly (from ~400MB to ~150MB).
- **Non-Root User**: Standard containers run as `root`. If a vulnerability is found in the application, an attacker could gain root access to the host. Running as a dedicated `django` user prevents this.
- **Environment Variables**: To avoid hardcoding sensitive information like `SECRET_KEY` and to make the application portable across different environments (Dev, Staging, Production).

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

**Action**: Created a multi-stage `Dockerfile` using `node:22-slim` and `vite preview`.

**Why?**
- **Production Server (`serve`)**: We opted for `serve` instead of `vite preview`. `preview` is a developer tool; `serve` is a light, robust, production-grade static file host. It handles the Single Page Application (SPA) routing logic (-s flag) and provides better security and performance for a Node-based host.
- **Multi-Stage Build**: Node applications have huge `node_modules`. By building the app in stage 1 and only copying the `dist` folder to stage 2, we keep the final image extremely lean.

**Code Snippet (Production Serving)**:
```dockerfile
CMD ["npx", "serve", "-s", "dist", "-l", "5173"]
```

---

### 3. Orchestration with Docker Compose

**Action**: Defined `docker-compose.yml` with networking and volume management.

**Why?**
- **Unified Management**: Running two separate `docker build` and `docker run` commands is error-prone. Compose allows starting the entire stack with a single command.
- **Service Dependency**: The frontend depends on the backend being available. `depends_on` ensures a cleaner startup sequence.
- **Volumes**: Used a named volume for the backend to ensure data persistence if needed (though currently using SQLite).

**Code Snippet (Orchestration)**:
```yaml
services:
  backend:
    build: ./backend
  frontend:
    build: ./frontend
    depends_on:
      - backend
```

---

### 4. Environment Management

**Action**: Added `.env.example` files.

**Why?**
- **Documentation**: It serves as a template for other developers to know exactly which variables are required without looking at the source code.
- **Security**: Ensures `.env` files (which contain real secrets) are never committed to version control.

---

## 🚀 Further Documentation
- 🚧 **[Challenges & Solutions (CHALLENGES.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/CHALLENGES.md)**: Deep dive into the hurdles overcome.
- 🚀 **[Quick Start Guide (README.md)](file:///home/rohit/Rohit/Nexgensis-devops-assessment/README.md)**: Foolproof instructions for teammates.
