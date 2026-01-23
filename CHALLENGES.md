# 🚧 Challenges & Solutions

This document highlights the major technical hurdles encountered during the dockerization of the Nexgensis DevOps Assessment project.

---

## 1. Final Node-Based Implementation (No Nginx)
### **The Problem**
Initial attempts failed due to:
1.  **Syntax Error**: `adduser` behavior inconsistencies in `node:slim`.
2.  **Permission Error**: `EACCES: mkdir '/nonexistent'` when `npx` tried to download packages at runtime.

### **The Solution**
- Used `useradd -m nodejs` for correct home directory creation.
- Pre-installed `serve` globally in the image to eliminate runtime downloads.
- Set `ENV HOME=/home/nodejs` to provide a writable cache space.

---

## 2. Dynamic CI/CD Branch Mapping
### **The Problem**
Teammates need automated deployments across multiple environments (`DEV`, `QA`, `PROD`).
### **The Solution**
Used a `case` statement in GitHub Actions to dynamically tag images (e.g., `prod-latest`, `qa-latest`) based on the active branch, enabling a single workflow to handle all deployment tiers.

---

## 3. Multi-Stage Build & Permission Denied Errors
### **The Problem**
Non-root users often cannot access files copied from the root-owned build stage.
### **The Solution**
Implemented `chown -R nodejs:nodejs /app` immediately after copying artifacts to the final stage.

---

## 4. Backend Dependency Management
### **The Problem**
Missing `requirements.txt` lead to non-reproducible builds.
### **The Solution**
Generated a pinned `requirements.txt` by analyzing the project imports and settings.

---

---

## 6. Organizational Action Restrictions
### **The Problem**
Security policies blocked third-party actions like `dorny/paths-filter`.
### **The Solution**
We replaced external actions with **native Git commands** and shell logic in the workflow. This achieved identical path-based filtering while complying with 100% of the repository's security policies.

---

## 7. Malformed SSH Secrets & "Connection Refused"
### **The Problem**
Copy-paste errors in `SSH_PRIVATE_KEY` (missing footers/new lines) lead to fragile deployments and manual intervention.
### **The Solution**
We pivoted to **AWS Systems Manager (SSM)**. By using AWS-native session management, we completely removed the need for SSH keys and Port 22, making the connection 100% reliable and significantly more secure.

---

## 8. Terraform "Already Exists" (Idempotency)
### **The Problem**
Redeployments would fail if IAM roles or Security Groups already existed in the account.
### **The Solution**
Implemented **Smart Resource Reuse**. By using `name_prefix` and conditional `data/resource` toggles, Terraform now intelligently detects existing infrastructure and reuses it instead of erroring out.

---

## 9. EC2 Boot Timing Gaps
### **The Problem**
Deployments failed because they started after the instance was "Running" but before the OS or SSM agent was fully initialized.
### **The Solution**
Implemented a robust **SSM Readiness Waiter** in the CI/CD pipeline that polls the agent status for up to 5 minutes, ensuring the environment is truly ready for deployment.
