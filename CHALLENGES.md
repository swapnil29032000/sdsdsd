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

---

## 4. Backend Dependency Management
### **The Problem**
Missing `requirements.txt` lead to non-reproducible builds.
### **The Solution**
Generated a pinned `requirements.txt` by analyzing the project imports and settings.

---

## 5. Infrastructure as Code (IaC) Complexity
### **The Problem**
Moving from local Docker to a Cloud VM requires manual setup of Docker, security groups, and ECR access, which is prone to human error.
### **The Solution**
We implemented **Infrastructure as Code (IaC)** using Terraform. This ensures that every time we deploy to AWS, the security groups and IAM roles are identical. We also used a user_data script to automate server configuration.

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

## 8. Terraform "Already Exists" & State Persistence
### **The Problem**
Redeployments would fail if the local state was lost, leading to "EntityAlreadyExists" errors even with `name_prefix`. S3/DynamoDB backends add cost and complexity.
### **The Solution**
Implemented **Git-Based State Management**. We now version the `terraform.tfstate` file directly in the repository. The CI/CD pipeline automatically commits and pushes the updated state back to the repository after every change. This ensures 100% idempotency without external cloud costs.

---

## 9. SSM CLI Versioning & The Deployment Bug
### **The Problem**
The `aws ssm send-command` failed with `Unknown options: --wait` because the GitHub runner's CLI version didn't support that specific flag.
### **The Solution**
We replaced the brittle `--wait` flag with a **Custom Native Waiter**. The pipeline now polls `aws ssm list-command-invocations` every 15 seconds, providing real-time logs and gracefully handling success/failure states.

---

## 10. Security Group Naming & Visibility
### **The Problem**
Infrastructure components were using `name_prefix`, resulting in generic names in the AWS console that lacked project-specific context and visibility.
### **The Solution**
Refactored the EC2 module to support **Explicit Naming**. We added a `security_group_name` variable and a descriptive `Name` tag, allowing users to define exactly how their security groups appear in the AWS console while still maintaining the "Smart Reuse" logic for idempotency.

---

## 12. The Bootstrap Paradox (Missing Images)
### **The Problem**
If ECR images are deleted (manual cleanup or fresh repository), the deployment job would fail during the initial infrastructure stand-up, as the `changes` job would skip builds if no code changed.
### **The Solution**
Implemented **Bootstrap Resilience**. The `changes` job now actively polls ECR for required image tags. If a tag is missing, it signals `bootstrap=true`, which forces the build jobs to run regardless of code diffs. This ensures a self-healing pipeline that always has its dependencies ready.

---

## 13. Ubuntu 24.04 Package Gaps (AWS CLI v2)
### **The Problem**
Ubuntu 24.04 (Noble) has discontinued the legacy `awscli` apt package, causing deployment failures with `No installation candidate`. 
### **The Solution**
Pivoted to the **Official AWS CLI v2 Binary Installer**. We integrated automated `curl`, `unzip`, and `./install` logic into both the Terraform `user_data` and the CI/CD's SSM command block. This ensures the correct, modern AWS CLI version is always present, regardless of AMI defaults.
---

## 11. Apt Lock Race Conditions
### **The Problem**
On fresh Ubuntu AMIs, background system updates (like `unattended-upgrades`) often start immediately on boot. This locks the `apt` package manager, causing automated Docker installations to fail with `Could not get lock /var/lib/apt/lists/lock`.
### **The Solution**
Implemented a robust **Apt Waiter** function in both the Terraform `user_data` and the CI/CD deployment script. This logic polls for existing locks and gracefully waits for them to be released before proceeding with dependency installation, ensuring 100% deployment reliability on any AMI.
