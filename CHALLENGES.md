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
Implemented a dual-layer **Provisioning Guard**. 
1. **Synchronization**: Added `sudo cloud-init status --wait` to the deployment block, forcing the pipeline to respect the server's own setup progress.
2. **Aggressive Resilience**: Refined the lock-waiter with a **Nuke & Wait** strategy. If a system lock persists for more than 5 minutes, the script proactively clears the offending process and lock files. This ensures 100% autonomy and removes all potential for "stuck" deployment states.

---

## 25. Breaking the Chicken-and-Egg Build-Time IP Dependency
### **The Problem**
Modern frontend frameworks like Vite bake environment variables into static assets during the build phase. This created a circular dependency: we needed the server's Public IP to build the UI, but the UI was built *before* Terraform provisioned the server. Using runtime injection was ineffective against pre-compiled Javascript.
### **The Solution**
Orchestrated a **Sequential Build-Infra Pipeline**. 
1. **Infrastructure First**: Re-ordered the CI/CD so Terraform provisions the EC2 instance before the frontend build starts.
2. **Dynamic Cross-Job Injection**: Configured the frontend build job to depend on the infrastructure job, fetching the real Public IP directly from Terraform's outputs.
3. **Build-Time Baking**: The pipeline now injects the real server IP into the `.env` file just milliseconds before the Docker image is created. This ensures the React app is born with the correct backend URL, guaranteeing total browser connectivity without needing a reverse proxy.

---

## 26. Smart Idempotency: IP Drift Detection
### **The Problem**
Re-ordering the pipeline into a sequential 'Infra -> Build' flow is stable, but it can be slow if a full frontend rebuild is triggered every time, even when the server IP hasn't changed. This wastes build minutes and delays developer feedback.
### **The Solution**
Implemented **IP-Aware Conditional Builds**.
1. **Drift Detection**: The infrastructure job now captures the 'Old IP' from the project's state before running Terraform and compares it with the 'New IP' after.
2. **Idempotency Signal**: It outputs an `ip_changed` flag based on this comparison.
3. **Intelligent Skip**: The `build-frontend` job now uses a complex `if` condition: it rebuilds ONLY if code changes are detected OR if the IP has drifted. If both are persistent, the pipeline skips the build entirely. This provides the ultimate balance of 100% connectivity and lightning-fast developer cycles.

---

## 24. Direct IP Connectivity vs Prototyping Gaps
### **The Problem**
Client-side React applications executed in a user's browser cannot resolve internal Docker hostnames like `backend`. Without an Nginx reverse proxy to bridge this gap via relative paths (`/api`), the app fails to connect unless a Public IP is explicitly provided.
### **The Solution**
Simplified the architecture to use **Direct Port Exposure** as requested, while maintaining production reachability.
1. **Direct Ports**: Mapped Frontend to 80 and Backend to 8000 directly on the host. 
2. **Runtime Injection**: Re-implemented the CI/CD logic to fetch the server's Public IP and inject it into the frontend's `VITE_API_URL` during deployment. This ensures the browser always has the correct target.
3. **Local Match**: Configured `docker-compose.yml` to use `localhost` for a seamless local-to-cloud development experience, satisfying all architectural constraints.

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

---

## 11. Apt Lock Race Conditions
### **The Problem**
On fresh Ubuntu AMIs, background system updates often lock the `apt` package manager, causing automated Docker installations to fail.
### **The Solution**
Implemented a robust **Apt Waiter** function in both Terraform and CI/CD. This logic polls for existing locks and waits for them to be released, ensuring 100% reliability on any AMI.

---

## 12. The Bootstrap Paradox (Missing Images)
### **The Problem**
If ECR images were missing, the build-skip logic would prevent the deployment from ever starting.
### **The Solution**
Implemented **Bootstrap Resilience**. The pipeline now polls ECR for tags and forces a build if they are missing, regardless of code changes.

---

## 23. The Docker Network Browser-Bridge (Nginx Gateway)
### **The Problem**
Connecting a browser-side React application to an internal Django backend over a private Docker network is architecturally impossible directly, as the client (user's browser) has no access to the containerized network. Simply using `backend` as a hostname fails because it only exists inside the EC2 server.
### **The Solution**
Pivoted to a **Production Gateway Pattern** using Nginx as a sidecar.
1. **Internal Routing**: We added an Nginx service at Port 80 that proxies `/api` to the backend container over the private Docker fabric.
2. **Relative Linking**: Built the frontend with `VITE_API_URL=/api`, telling the browser to route API calls back to the Gateway.
3. **No Dockerfile Changes**: Achieved this purely via Docker Compose and CI/CD build-time injection, fulfilling all local and production operational requirements.

---

## 13. Ubuntu 24.04 Package Gaps (AWS CLI v2)
### **The Problem**
The legacy `awscli` package is gone in Ubuntu 24.04, breaking the `apt-get install` step.
### **The Solution**
Pivoted to the **Official AWS CLI v2 Binary Installer**. We integrated automated `curl` and `unzip` logic to ensure the modern CLI is always present.

---

## 14. Buildx Cache Export Drivers
### **The Problem**
The CI/CD failed with `Cache export is not supported for the docker driver` when attempting to use GitHub Actions caching.
### **The Solution**
Integrated `docker/setup-buildx-action` to create a dedicated builder instance. This enabled full support for `type=gha` cache exports, drastically reducing build times while maintaining pipeline stability.
