# 🚀 CI/CD Pipeline with GitHub Actions

This document provides foolproof instructions on how the CI/CD pipeline is structured, how to trigger it, and what secrets are required for successful deployment to AWS ECR.

---

## 🏗 Pipeline Overview

The pipeline consists of two separate workflows:
1.  **Frontend Image Push**: Triggered by changes in the `frontend/` directory.
2.  **Backend Image Push**: Triggered by changes in the `backend/` directory.

### Branch Mapping & Tagging Strategy

We use a dynamic tagging strategy based on the branch being pushed:

| Branch | Environment | Image Tag |
| :--- | :--- | :--- |
| `main` | Production | `prod-latest` + `SHORT_SHA` |
| `PREPROD` | Pre-Production | `preprod-latest` + `SHORT_SHA` |
| `QA` | Quality Assurance | `qa-latest` + `SHORT_SHA` |
| `DEV` | Development | `dev-latest` + `SHORT_SHA` |

---

## 🛠 Prerequisites & Setup

To ensure a teammate can follow this without asking questions, follow these steps exactly:

### 1. AWS Infrastructure Requirements

#### 🛡️ AWS OIDC Setup (Identity Provider)
Following the [official AWS instructions](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/), you must configure GitHub as a trusted Identity Provider (IdP) in your AWS account to avoid using long-lived access keys.

**Step-by-Step Console Guide:**
1.  **Create Identity Provider**:
    - Go to **IAM > Identity providers > Add provider**.
    - **Provider type**: `OpenID Connect`.
    - **Provider URL**: `https://token.actions.githubusercontent.com` (Click "Get thumbprint").
    - **Audience**: `sts.amazonaws.com`.
2.  **Create IAM Role for GitHub Actions**:
    - Create a new role named `github-cicd`.
    - **Trusted entity**: `Web identity`.
    - **Identity provider**: Select the one created above.
    - **Audience**: `sts.amazonaws.com`.
3.  **Configure Trust Relationship**:
    Update the "Trust relationships" tab with the following policy (replacing `<ORG/REPO>` with your repository path):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:Rohit27305/Nexgensis-devops-assessment:ref:refs/heads/*"
        },
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      }
    }
  ]
}
```

- **IAM Role Permissions**: Attach a policy to this role that allows `ecr:*` actions for the `nexgensis` repository.

#### 📦 ECR Repositories
The pipeline is designed to **automatically create** the required ECR repositories (e.g., `nexgensis/nexgensis-frontend`) if they do not exist. You do not need to create them manually.

### 2. GitHub Secrets Configuration
Navigate to **Settings > Secrets and variables > Actions** in your repository and add the following secrets:

| Secret Name | Description | Example |
| :--- | :--- | :--- |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS Account ID | `123456789012` |
| `ECR_REGISTRY` | The URI of your ECR registry | `123456789012.dkr.ecr.us-east-1.amazonaws.com` |
| `FE_PROD_ENV` | Frontend production `.env` contents | `VITE_API_URL=...` |
| `FE_DEFAULT_ENV` | Fallback `.env` for Frontend | `VITE_API_URL=...` |

> [!IMPORTANT]
> **Backend Secrets**: Backend images do **not** have secrets baked into them during the build process. You must configure environment variables (or the `.env` file) directly in your deployment platform (e.g., AWS ECS Task Definition, K8s Secrets, or local Docker Compose).

---

## 🚦 How to Trigger the Pipeline

1.  **Develop**: Make your changes in a feature branch.
2.  **Commit & Push**: Push your changes to one of the tracked branches (`DEV`, `QA`, `PREPROD`, or `main`).
3.  **Monitor**: Go to the **Actions** tab in GitHub to watch the build and push progress.

### Path Filters
To optimize execution time, the workflows only trigger if changes are detected in their respective folders:
- Frontend changes only trigger `frontend-img-push`.
- Backend changes only trigger `backend-img-push`.

---

## 🛡 Security Practices

- **OIDC (OpenID Connect)**: We do **not** store long-lived AWS Access Keys in GitHub. We use temporary credentials via OIDC for enhanced security.
- **Least Privilege**: The IAM role should only have `ecr:GetAuthorizationToken` and push permissions for the specific repositories.

---
*Maintained by Antigravity AI for Nexgensis.*
