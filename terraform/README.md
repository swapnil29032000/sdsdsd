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
- **Port 443**: Secure Traffic.
- **Port 22**: Administrative (SSH) Access.
