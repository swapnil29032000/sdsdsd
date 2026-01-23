# 🛠️ DevOps, Infrastructure & Deployment Guide

This document is the **single source of truth** for the Nexgensis technical stack, covering AWS security, modular infrastructure, and the unified SSH-less (SSM) GitOps pipeline.

---

## 🛡️ 1. AWS Requirements & Permissions

To successfully run this pipeline, two specific IAM configuration sets are required.

### A. GitHub Actions (OIDC Role)
We use **OpenID Connect (OIDC)** to authenticate GitHub with AWS without storing permanent keys.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*", "ec2:*", "iam:*", "vpc:*", "s3:*", 
        "ssm:SendCommand", "ssm:DescribeInstanceInformation"
      ],
      "Resource": "*"
    }
  ]
}
```

### B. EC2 Instance Profile
The application server requires a role with:
- `AmazonEC2ContainerRegistryReadOnly` (to pull images)
- `AmazonSSMManagedInstanceCore` (to enable SSH-less deployment via SSM)

---

## 🏗️ 2. Modular Infrastructure (Terraform)

The infrastructure is built using reusable modules for networking, compute, and security.

### Essential Security Rules
The following Ports are open on the infrastructure level:
- **Port 80**: Application Frontend (Public).
- **Port 22**: Administrative SSH Access (Optional, can be closed for max security).

> [!NOTE]
> Our deployment process **does not use SSH (Port 22)**. It uses AWS Systems Manager (SSM) to securely tunnel commands to the server.

---

---

## 🚀 3. Unified GitOps Pipeline (cicd.yaml)

The project uses a single **Production Pipeline** to orchestrate the "Build-First" strategy.

### ⚡ Intelligent Build Triggers
We use native path-based filtering to skip redundant builds and optimize resource usage.
```yaml
# Logic in cicd.yaml
backend:
  - 'backend/**'
frontend:
  - 'frontend/**'
```

### 🛡️ Robust Secret Selection & Fallback
The pipeline intelligently selects environment-specific secrets (e.g., `BE_DEV_ENV`) based on the active branch and automatically falls back to **`BE_DEFAULT_ENV`** if a specific secret is missing or empty. This prevents pipeline failures due to unset secrets.

### 🌉 The SSM Deployment Guard (SSH-less)
Instead of error-prone SSH keys, the pipeline uses **AWS Systems Manager (SSM)**.
```bash
aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters "commands=['sudo docker compose pull', 'sudo docker compose up -d']"
```

### 💎 Zero-Downtime Rolling Update
The deployment strategy ensures that new images are pulled **before** the existing containers are recreated. Combined with Docker's `--remove-orphans`, this minimizes service interruption during updates.

---

## 🛠️ Required GitHub Secrets

| Secret Name | Description |
| :--- | :--- |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS Account ID. |
| `ECR_REGISTRY` | The URI of your AWS ECR Registry. |
| `BE_PROD_ENV` / `BE_DEFAULT_ENV` | Django environment variables. |

> [!IMPORTANT]
> **No SSH_PRIVATE_KEY is required.** The pipeline is fully managed via AWS-native permissions.

---

## 🛠️ 4. Troubleshooting & Connectivity

### A. Deployment via SSM Fails
- **Check Instance Status**: The instance must be "Online" in AWS SSM Fleet Manager.
- **IAM Consistency**: Ensure the EC2 Instance Profile has `AmazonSSMManagedInstanceCore` attached.
- **Wait Time**: For fresh instances, it can take 2-3 minutes for the SSM agent to start after boot.

### B. Smart Resource Reuse
If you receive `EntityAlreadyExists` for an IAM role:
- Set `create_iam_role = false` and `existing_iam_role_name = "your-role-name"` in your terraform variables.

---

## 🛡️ 5. Smart Resource Reuse & Idempotency

### A. Bypassing "EntityAlreadyExists"
If an IAM role already exists in your AWS account, set `create_iam_role = false` to use a **`data` source** to fetch it instead of attempting a `resource` creation.

### B. Collision Resilience (`name_prefix`)
We use `name_prefix` for Security Groups and IAM roles to allow AWS to generate unique suffixes, ensuring the `apply` always succeeds.

---

## 🗺️ 6. The Project Journey & Challenges

Building this pipeline involved overcoming several major technical hurdles (SSM, Smart Reuse, OIDC security, etc.).

For a detailed chronological account of every challenge we faced and exactly how we solved it, please refer to the dedicated:

👉 **[CHALLENGES.md](file:///home/rohit/Rohit/Nexgensis-devops-assessment/CHALLENGES.md)**
