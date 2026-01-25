# DevOps Assessment Application

[![Docker Build](https://img.shields.io/badge/docker-build-blue.svg)](https://hub.docker.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A full-stack "Hello World" application built with **Django** (Backend) and **React with Vite** (Frontend), containerized with Docker and automated with CI/CD.

## 🚀 Quick Start with Docker

```bash
# Clone the repository
git clone https://github.com/Nexgensis/devops-assessment.git
cd devops-assessment

# Start with Docker Compose
docker-compose up -d

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:8000/api/hello/
```

## 📋 Project Overview

- **Backend**: Django 6.0 (REST API) with Gunicorn
- **Frontend**: React 19.2 (Vite, TypeScript, Lucide Icons)
- **Styling**: Premium custom CSS with dark/light mode support
- **Communication**: REST API using Axios with CORS enabled
- **Containerization**: Docker multi-stage builds with Alpine Linux
- **Orchestration**: Docker Compose
- **CI/CD**: GitHub Actions with automated Docker Hub deployments

## 🏗️ Architecture

```
┌─────────────────┐         ┌─────────────────┐
│  React Frontend │ ◄─────► │  Django Backend │
│   (Nginx:80)    │  HTTP   │  (Gunicorn:8000)│
│   Alpine Linux  │         │  Alpine Linux   │
└─────────────────┘         └─────────────────┘
        │                           │
        └───────────┬───────────────┘
                    │
            Docker Network
```

## 📦 Prerequisites

### Option 1: Docker (Recommended)
- Docker 24.0+
- Docker Compose 2.0+

### Option 2: Local Development
- Python 3.10+
- Node.js 18+
- npm 9+

## 🐳 Docker Setup (Recommended)

### Using Docker Compose

```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Manual Docker Build

```bash
# Backend
cd backend
docker build -t devops-backend:latest .
docker run -p 8000:8000 devops-backend:latest

# Frontend
cd frontend
docker build --build-arg VITE_API_URL=http://localhost:8000 -t devops-frontend:latest .
docker run -p 3000:80 devops-frontend:latest
```

### Environment Configuration

Copy `.env.example` to `.env` and configure:

```env
DJANGO_DEBUG=False
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1
DJANGO_CORS_ALLOWED_ORIGINS=http://localhost:3000
VITE_API_URL=http://localhost:8000
```

## 💻 Local Development Setup

### Backend Setup

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Create and activate virtual environment:
   ```bash
   python -m venv venv
   venv\Scripts\activate  # Windows
   source venv/bin/activate  # Linux/Mac
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run development server:
   ```bash
   python manage.py runserver
   ```

   Backend available at: `http://localhost:8000/api/hello/`

### Frontend Setup

1. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start development server:
   ```bash
   npm run dev
   ```

   Frontend available at: `http://localhost:5173/`

## 🔄 CI/CD Pipeline

GitHub Actions automatically:
- ✅ Builds Docker images on push to `main` branch
- ✅ Runs security scans and health checks
- ✅ Pushes images to Docker Hub
- ✅ Deploys to configured environment

**Required GitHub Secrets:**
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `VITE_API_URL` (optional, for production API URL)

## 📚 Documentation

For comprehensive documentation including:
- Architecture diagrams
- Detailed setup instructions
- Deployment guides (AWS/Azure/GCP)
- Troubleshooting common issues
- CI/CD pipeline configuration
- Maintenance and operations

**See [DEVOPS.md](DEVOPS.md) for complete documentation.**

## 🔒 Security Features

- ✅ Multi-stage Docker builds for minimal attack surface
- ✅ Non-root users in all containers
- ✅ No hardcoded secrets (environment variables)
- ✅ CORS properly configured
- ✅ Security headers in Nginx
- ✅ Automated security scanning with Trivy

## 📊 Best Practices

- **Image Optimization**: Multi-stage builds reduce image sizes (Frontend: ~40MB, Backend: ~180MB)
- **Health Checks**: Automated container health monitoring
- **Logging**: Structured logs for debugging
- **Caching**: Docker layer caching for faster builds
- **Documentation**: Comprehensive setup and troubleshooting guides

## 🎯 Assessment Checklist

- [x] Phase 1: Containerization
  - [x] Multi-stage Dockerfiles (Backend & Frontend)
  - [x] Non-root users
  - [x] Docker Compose orchestration
  - [x] Environment variable configuration

- [x] Phase 2: CI/CD Pipeline
  - [x] GitHub Actions workflows
  - [x] Automated Docker builds
  - [x] Docker Hub integration
  - [x] Deployment automation

- [x] Phase 4: Documentation
  - [x] Comprehensive DEVOPS.md
  - [x] Setup guides
  - [x] Troubleshooting log
  - [x] Architecture documentation

## 🖼️ Screenshots

> Screenshots will be added after deployment

## 📞 Support

For issues or questions, see the [Troubleshooting](DEVOPS.md#troubleshooting) section in DEVOPS.md.

---

**Developed for Nexgensis DevOps Assessment**
