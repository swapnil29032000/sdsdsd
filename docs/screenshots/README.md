# Screenshots Directory

This directory contains screenshots of the application in various stages:

## Required Screenshots

1. **local-running.png** - Application running locally with Docker Compose
2. **docker-containers.png** - Docker containers running (`docker ps`)
3. **cicd-pipeline.png** - GitHub Actions workflow success
4. **production-deployment.png** - Application running in production (if deployed)
5. **docker-hub.png** - Docker images in Docker Hub registry

## How to Capture

### Local Running
```bash
docker-compose up -d
# Open browser to http://localhost:3000
# Take screenshot of the application
```

### Docker Containers
```bash
docker ps
# Take screenshot of terminal showing running containers
```

### CI/CD Pipeline
- Go to GitHub repository > Actions tab
- Take screenshot of successful workflow run

### Docker Hub
- Go to hub.docker.com > Your repositories
- Take screenshot showing pushed images

## Uploading Screenshots

Place screenshots in this directory with the exact filenames listed above.
