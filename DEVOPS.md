# 🛠️ DevOps, Infrastructure & Deployment Guide

This document is the **single source of truth** for the Nexgensis technical stack, covering AWS security, modular infrastructure, and the unified GitOps pipeline.

---

## 🛡️ 1. AWS Requirements & Permissions

To successfully run this pipeline, two specific IAM configuration sets are required.

### A. GitHub Actions (OIDC Role)
We use **OpenID Connect (OIDC)** to authenticate GitHub with AWS without storing permanent keys.
```yaml
# Permission required in cicd.yaml
permissions:
  id-token: write
  contents: read
```

The IAM role assumed by GitHub must have a policy allowing management of the following services:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*", "ec2:*", "iam:*", "vpc:*", "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### B. EC2 Instance Profile
The application server requires a role with the `AmazonEC2ContainerRegistryReadOnly` policy attached, allowing it to pull images from AWS ECR securely.

---

## 🏗️ 2. Modular Infrastructure (Terraform)

The infrastructure is built using reusable modules for networking, compute, and security.

```hcl
# Example module integration from main.tf
module "vpc" { source = "./modules/vpc" }
module "ec2" {
  source           = "./modules/ec2"
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_id
  key_name         = "my-aws"
}
```

### Essential Security Rules
The following Ports are open on the infrastructure level:
- **Port 80**: Application Frontend (Public).
- **Port 22**: Administrative SSH Access.

---

## 🚀 3. Unified GitOps Pipeline (cicd.yaml)

The project uses a single **Production Pipeline** to orchestrate the "Build-First" strategy.

### ⚡ Intelligent Build Triggers
We use path-based filtering to skip redundant builds.
```yaml
# Snippet from cicd.yaml
backend:
  - 'backend/**'
frontend:
  - 'frontend/**'
```

### 🛡️ Robust Secret Selection & Fallback
The pipeline intelligently selects branch-specific secrets (e.g., `BE_DEV_ENV`) and automatically falls back to **`BE_DEFAULT_ENV`** if they are missing or empty.
```bash
# Selection logic flow
If BRANCH_SECRET exists -> Use it
Else -> Fallback to BE_DEFAULT_ENV
```

---

## � 4. Resilient Deployment & Zero-Downtime

### 🌉 The SSH Health Guard
Upon provisioning new infrastructure, the pipeline uses a retry loop to wait for the OS and SSH service to reach a "Ready" state.
```bash
for i in {1..30}; do
  ssh-keyscan -H $IP >> ~/.ssh/known_hosts && \
  ssh -i key.pem ubuntu@$IP "echo Ready" && break
  sleep 10
done
```

### 🛠️ Auto-Healing Dependency Guard
The deployment script automatically detects and installs missing dependencies (**Docker, AWS CLI, Docker Compose**) on the target host.
```bash
if ! command -v docker &> /dev/null; then
  sudo apt-get update && sudo apt-get install -y docker.io
fi
```

### 💎 Zero-Downtime Rolling Update
We download new images first and then recreate containers locally to avoid any service interruption.
```bash
sudo docker compose pull
sudo docker compose up -d --remove-orphans
```

---

## 🛠️ Required GitHub Secrets

| Secret Name | Description |
| :--- | :--- |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS Account ID. |
| `ECR_REGISTRY` | The URI of your AWS ECR Registry. |
| `SSH_PRIVATE_KEY` | The contents of your `my-aws.pem` file. |
| `BE_DEFAULT_ENV` | Fallback environment variables for the backend. |

---

## 🛠️ 5. Troubleshooting & Connectivity

### A. SSH Permission Denied (UNPROTECTED PRIVATE KEY)
**Error**: `WARNING: UNPROTECTED PRIVATE KEY FILE! Permissions 0664 for 'my-aws.pem' are too open.`
**Cause**: OpenSSH rejects keys that are readable by other users on your system.
**Fix**:
```bash
chmod 400 my-aws.pem
ssh -i my-aws.pem ubuntu@<INSTANCE_IP>
```

### B. Deployment Timing Gaps
If you receive `Connection Refused` immediately after infrastructure creation:
- **Reason**: AWS EC2 instances report "Running" before the OS boot process is complete.
- **Handled**: Our pipeline includes an automated retry loop that waits up to 5 minutes for the host to become reachable.

### C. Missing Host Dependencies
If the target server is a fresh AMI:
- **Handled**: The **Dependency Guard** in `cicd.yaml` will automatically install Docker and AWS CLI during the first deployment.

---

### D. Malformed SSH_PRIVATE_KEY
If the pipeline fails at the "Prepare SSH Identity" step:
- **Error**: `id_rsa is not a key file` or `The provided SSH_PRIVATE_KEY is malformed`.
- **Diagnostics**: Check the **"SSH Key Diagnostic Info"** printout in the GitHub Action logs.
- **Common Fixes**:
  - Ensure the key includes the `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` lines.
  - Check that the key is **not** base64 encoded when pasted into GitHub Secrets (it should be raw text).
  - Avoid extra spaces at the end of the key.

---

## 🛡️ 6. Smart Resource Reuse & Idempotency

To ensure 100% reliability, the infrastructure supports **Conditional Creation**.

### A. Bypassing "EntityAlreadyExists"
If an IAM role already exists in your AWS account and you want to reuse it instead of creating a new one:
1.  Set `create_iam_role = false` in your variables.
2.  Specify the name in `existing_iam_role_name`.

This tells Terraform to use a **`data` source** to fetch the existing role instead of attempting a `resource` creation, completely bypassing the 409 Conflict error.

### B. Collision Resilience (`name_prefix`)
For resources where uniqueness is desired but collisions are common (Security Groups), we use `name_prefix`. This allows AWS to generate a unique suffix, ensuring the `apply` always succeeds.

---
