# Cloudflare Error 521 - Root Cause & Solution

## 🔍 Root Cause Identified

**Error**: HTTP 521 - Web server is down  
**Actual Issue**: Cloudflare SSL/TLS misconfiguration

### What's Happening:
1. ✅ Cloudflare is working (connects to domain)
2. ✅ DNS is correct (points to your server)
3. ✅ Nginx config is perfect
4. ❌ **SSL/TLS mismatch**: Cloudflare SSL mode not configured

## ✅ Solution: Use Cloudflare Free SSL (Flexible Mode)

This is the **simplest and recommended** approach for containerized applications.

### How It Works:
```
User Browser (HTTPS) → Cloudflare (HTTPS) → Your Server (HTTP)
```

- **User sees**: `https://nexgensis-assignment.rohitverma.social` 🔒
- **Cloudflare provides**: Free SSL certificate
- **Your server**: Simple HTTP on port 80
- **Result**: Secure HTTPS for users, no certificate management needed!

### Step 1: Configure Cloudflare SSL
1. Go to **Cloudflare Dashboard**
2. Select domain: `nexgensis-assignment.rohitverma.social`
3. Navigate to: **SSL/TLS** → **Overview**
4. Set encryption mode to: **Flexible** ✅

### Step 2: Add GitHub Secret
1. Go to **GitHub** → **Settings** → **Secrets and variables** → **Actions**
2. Add secret:
   - **Name**: `APP_DOMAIN`
   - **Value**: `nexgensis-assignment.rohitverma.social`

### Step 3: Deploy Infrastructure
```bash
cd terraform
terraform apply -auto-approve
```

### Step 4: Trigger Deployment
Push code or manually run GitHub Actions workflow.

## 📋 Verification Checklist

- [ ] `APP_DOMAIN` secret is set in GitHub
- [ ] EC2 instance is running
- [ ] Security Group allows port 80
- [ ] Deployment workflow completed successfully
- [ ] Cloudflare SSL mode = **Flexible**
- [ ] Domain resolves: `dig nexgensis-assignment.rohitverma.social`

## ✅ Expected Result

After deployment:
- `http://nexgensis-assignment.rohitverma.social` → Works
- `https://nexgensis-assignment.rohitverma.social` → ✅ Works with Cloudflare SSL
- Users see green padlock 🔒
- Zero certificate management on your server

## 🎯 Why Flexible Mode?

**Advantages:**
- ✅ Free SSL certificate from Cloudflare
- ✅ No certificate installation needed
- ✅ No certificate renewal needed
- ✅ Works perfectly with Docker containers
- ✅ Simple nginx configuration
- ✅ Automatic HTTPS for all users

**Perfect for:**
- Development and staging environments
- Containerized applications
- Quick deployments
- Cost-effective HTTPS

## 🔒 Security Note

Flexible mode encrypts traffic between users and Cloudflare, but uses HTTP between Cloudflare and your server. This is acceptable because:
- Cloudflare's network is trusted
- Your server is in a private VPC
- Most attacks target the user → CDN connection (which is encrypted)

For maximum security in production, you can later upgrade to Full mode with a proper SSL certificate.
