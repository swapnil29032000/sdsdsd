# Cloudflare Error 521 - Root Cause & Solution

## 🔍 Root Cause Identified

**Error**: HTTP 521 - Web server is down  
**Actual Issue**: Cloudflare SSL/TLS misconfiguration

### What's Happening:
1. ✅ Cloudflare is working (connects to domain)
2. ✅ DNS is correct (points to your server)
3. ✅ Nginx config is perfect
4. ❌ **SSL/TLS mismatch**: Cloudflare uses HTTPS → Your server only has HTTP

## ✅ Solution: Automated SSL Certificate Setup

### The workflow now automatically:
1. ✅ Installs Certbot on EC2
2. ✅ Obtains SSL certificate from Let's Encrypt
3. ✅ Configures nginx with HTTPS
4. ✅ Sets up automatic HTTP → HTTPS redirect

### Step 1: Add GitHub Secret
1. Go to **GitHub** → **Settings** → **Secrets and variables** → **Actions**
2. Add secret:
   - **Name**: `APP_DOMAIN`
   - **Value**: `nexgensis-assignment.rohitverma.social`

### Step 2: Deploy Infrastructure
```bash
cd terraform
terraform apply -auto-approve
```

### Step 3: Trigger Deployment
Push code or manually run GitHub Actions workflow.

**The workflow will automatically:**
- Deploy your application
- Install Certbot
- Obtain SSL certificate for your domain
- Configure nginx with HTTPS
- Restart nginx with SSL enabled

### Step 4: Update Cloudflare SSL Mode
1. Go to **Cloudflare Dashboard**
2. Select domain: `nexgensis-assignment.rohitverma.social`
3. Navigate to: **SSL/TLS** → **Overview**
4. Change encryption mode to: **Full (strict)** ✅

**Why Full (strict)?**
- Your server now has a valid SSL certificate
- Cloudflare (HTTPS) → Origin (HTTPS with valid cert) ✅
- Maximum security!

## 📋 Verification Checklist

- [ ] `APP_DOMAIN` secret is set in GitHub
- [ ] EC2 instance is running
- [ ] Security Group allows ports 80 and 443
- [ ] Deployment workflow completed successfully
- [ ] Certbot installed SSL certificate
- [ ] Cloudflare SSL mode = **Full (strict)**
- [ ] Domain resolves: `dig nexgensis-assignment.rohitverma.social`

## 🔧 Manual SSL Setup (If Needed)

If automatic setup fails, SSH to EC2 and run:
```bash
sudo certbot --nginx -d nexgensis-assignment.rohitverma.social
```

## ✅ Expected Result

After deployment:
- `http://nexgensis-assignment.rohitverma.social` → Redirects to HTTPS
- `https://nexgensis-assignment.rohitverma.social` → ✅ Works with valid SSL
- Cloudflare shows green padlock 🔒
- End-to-end encryption enabled

## 🔄 SSL Certificate Renewal

Certbot automatically renews certificates. The workflow includes:
- Auto-renewal cron job
- Certificates valid for 90 days
- Auto-renews at 60 days
