# 🎡 Unified CI/CD & GitOps Guide

This document deep-dives into the **Production Pipeline (`cicd.yaml`)** and the architectural decisions that ensure speed, security, and 100% uptime.

---

## 🏗 Pipeline Architecture: The "Build-First" Strategy

### 1. Build & Push (Intelligent & Parallel)
- **Why Path Filtering?**: We use `dorny/paths-filter` to skip building the frontend if only the backend was changed. 
- **Robust Secret Fallback**: The pipeline is designed to search for branch-specific secrets (e.g., `BE_DEV_ENV`) and automatically fall back to `BE_DEFAULT_ENV` if they are missing or empty. This prevents pipeline failures during environment setup.
```bash
# Logical selection flow
If BRANCH_SECRET exists -> Use it
Else -> Use BE_DEFAULT_ENV
```

### 2. Infrastructure (Modular Terraform)
- **Why OIDC?**: We use **OpenID Connect** for passwordless authentication between GitHub and AWS.
```yaml
# OIDC Permission
permissions:
  id-token: write
  contents: read
```

### 3. SSH Deployment (Resilient & Zero-Downtime)
- **The SSH Waiter**: We use a retry loop to wait for the instance OS to be ready.
```bash
for i in {1..30}; do
  ssh-keyscan -H $IP >> ~/.ssh/known_hosts && \
  ssh -i key.pem ubuntu@$IP "echo Ready" && break
  sleep 10
done
```
- **The "Dependency Guard"**: Automatically installs required tools if they are missing on the target host.
```bash
if ! command -v docker &> /dev/null; then
  sudo apt-get update && sudo apt-get install -y docker.io
fi
```
- **Zero-Downtime Strategy**: Rolling updates using `pull` and `up -d`.
```bash
sudo docker compose pull
sudo docker compose up -d --remove-orphans
```

---

## 🛠 Required GitHub Secrets

| Secret Name | Purpose |
| :--- | :--- |
| `AWS_ACCOUNT_ID` | Used for OIDC authentication. |
| `SSH_PRIVATE_KEY` | The `.pem` content for secure server access. |
| `BE_PROD_ENV` | Runtime secrets for the Django backend. |

---

## 🚦 Handling Environments

We use branch-based environment tags:
- **`main`** ⮕ `prod-latest`
- **`QA`** ⮕ `qa-latest`
- **`DEV`** ⮕ `dev-latest`