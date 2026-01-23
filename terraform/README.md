## 🏗 Modular Architecture Overview

Our infrastructure is split into three core modules for professional isolation:
- **`modules/vpc`**: Networking foundation.
- **`modules/iam`**: Access control rules.
- **`modules/ec2`**: Compute resources.

### Example Module Configuration
```hcl
module "ec2" {
  source           = "./modules/ec2"
  frontend_repo    = var.frontend_repo_name
  backend_repo     = var.backend_repo_name
  frontend_image_tag = var.frontend_image_tag
}
```

---

## 🛡️ Idempotency & Collision Handling

The infrastructure is designed to be **self-healing** and **collision-resistant**.

### A. Automatic Resource Reuse
Terraform inherently avoids recreating resources that are already part of its tracking state. 
- If you run `apply` twice, Terraform detects no changes and skips the creation.
- **Tip**: To maintain this behavior across different environments, ensure you are using a consistent state (S3 backend is the production standard).

### B. Collision Protection (`name_prefix`)
To prevent fatal "Resource Already Exists" errors (common with IAM roles and Security Groups), we use `name_prefix` instead of static names.
```hcl
# Instead of name = "fixed-name"
name_prefix = "nexgensis-sg-"
```
If a conflicting resource is found in your AWS account that isn't in your current state, Terraform will automatically append a unique suffix to the new resource, allowing the deployment to proceed without failure.

---

## 🎡 Lifecycle in CI/CD

Controlled via the **Unified CI/CD Pipeline (`cicd.yaml`)**:
```bash
# The lifecycle steps
1. Build Images
2. terraform apply
3. scp docker-compose.yml
4. remote execute 'up -d'
```

---

## 🚀 Local Administration

To manage locally for testing or debugging:

### 🛠 Setup & Launch
```bash
terraform init
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars then:
terraform apply -auto-approve
```

---

## 🛡 Network & Security Rules
The following ports are mandatory for the application to function:
- **Port 80**: Public Web Traffic.
- **Port 22**: Administrative (SSH) Access.
