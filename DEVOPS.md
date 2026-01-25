# DevOps Assessment – Full Stack Deployment

## Project Overview
This project demonstrates containerization, orchestration, and CI/CD automation
for a full-stack application.

**Backend:** Django (REST API)  
**Frontend:** React (Vite + TypeScript)  

---

## Phase 1: Containerization

### Backend
- Dockerized using Python slim image
- Dependencies installed via requirements.txt
- Exposed on port 8000

### Frontend
- Dockerized using Node Alpine image
- Built using npm
- Exposed on port 3000

### Orchestration
- docker-compose used to run both services
- Services communicate via internal Docker network
- Ports mapped to localhost for browser access

### Run Locally
```bash
docker compose up --build
