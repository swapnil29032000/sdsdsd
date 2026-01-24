# Domain Configuration with Cloudflare SSL

Complete guide to setting up custom domains with free Cloudflare SSL certificates.

---

## Overview

Your application supports custom domains via GitHub Secrets with **automatic Cloudflare SSL integration**. Users see HTTPS without any certificate management on your server.

---

## Setup Instructions

### 1. Add Domain Secret to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add:
   - **Name**: `APP_DOMAIN`
   - **Value**: `nexgensis-assignment.rohitverma.social`

### 2. Configure Cloudflare

#### A. Add DNS Record
Point your domain to the EC2 instance:

```
Type: A Record
Name: nexgensis-assignment (or @)
Value: <EC2_PUBLIC_IP>
TTL: Auto (or 300)
```

#### B. Enable SSL (Flexible Mode)
1. Go to **Cloudflare Dashboard**
2. Select your domain
3. Navigate to: **SSL/TLS** → **Overview**
4. Set encryption mode to: **Flexible**

**Why Flexible?**
- Cloudflare provides free SSL certificate
- Your server uses simple HTTP
- Users see HTTPS with green padlock 🔒
- Zero certificate management needed

### 3. Deploy

Push code or trigger GitHub Actions workflow manually.

**The workflow automatically:**
1. Reads `APP_DOMAIN` secret
2. Replaces `DOMAIN_PLACEHOLDER` in nginx.conf
3. Deploys updated configuration to EC2

**Fallback**: If `APP_DOMAIN` is not set, uses EC2 IP address.

---

## How It Works

### Architecture

```
User Browser (HTTPS) 🔒
    ↓
Cloudflare (Free SSL Certificate)
    ↓
Your Server (HTTP on Port 80)
    ↓
Nginx Gateway → Backend/Frontend
```

### nginx.conf Template (Repository)
```nginx
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    # ... proxy configuration
}
```

### Workflow Replacement Logic
```bash
# Read domain from GitHub Secret
DOMAIN="${{ secrets.APP_DOMAIN }}"

# Replace placeholder with actual domain
sed "s|DOMAIN_PLACEHOLDER|$DOMAIN|g" nginx.conf > /tmp/nginx.conf

# Encode and deploy
ENCODED_NGINX=$(base64 -w 0 < /tmp/nginx.conf)
```

### Deployed nginx.conf (EC2)
```nginx
server {
    listen 80;
    server_name nexgensis-assignment.rohitverma.social;
    # ... proxy configuration
}
```

---

## Testing

### Test Domain Replacement Locally
```bash
sed "s|DOMAIN_PLACEHOLDER|your-domain.com|g" nginx.conf
```

### Verify DNS Propagation
```bash
dig nexgensis-assignment.rohitverma.social
```

### Check Deployed Configuration
```bash
docker exec nexgensis-gateway cat /etc/nginx/nginx.conf
```

---

## Troubleshooting

### Domain Not Resolving
**Symptoms**: Cannot access domain
**Solutions**:
- Check DNS propagation: `dig your-domain.com`
- Verify A record points to correct EC2 IP
- Wait 5-10 minutes for DNS propagation

### Error 521 (Web Server Down)
**Symptoms**: Cloudflare shows "Web server is down"
**Solutions**:
- Verify EC2 instance is running
- Check Security Group allows port 80
- Ensure Docker containers are running: `docker ps`
- Set Cloudflare SSL mode to **Flexible**

### Nginx Not Using Domain
**Symptoms**: Domain not recognized by nginx
**Solutions**:
- Verify `APP_DOMAIN` secret is set in GitHub
- Check deployed nginx.conf (see command above)
- Restart nginx: `docker restart nexgensis-gateway`

### 502 Bad Gateway
**Symptoms**: Nginx returns 502 error
**Solutions**:
- Check backend/frontend containers: `docker ps`
- View nginx logs: `docker logs nexgensis-gateway`
- View backend logs: `docker logs nexgensis-backend`
- Verify Docker network connectivity

---

## Benefits of Cloudflare SSL

✅ **Free SSL Certificate** - No cost for HTTPS  
✅ **Auto-Renewal** - Cloudflare manages certificates  
✅ **Zero Configuration** - No Certbot or Let's Encrypt needed  
✅ **Works with Docker** - No host-level certificate installation  
✅ **CDN Included** - Faster global performance  
✅ **DDoS Protection** - Built-in security features  

---

## Security Note

**Flexible SSL Mode** encrypts traffic between users and Cloudflare, but uses HTTP between Cloudflare and your server.

**This is acceptable because:**
- Cloudflare's network is trusted
- Your server is in a private VPC
- Most attacks target user → CDN connection (encrypted)
- Cloudflare provides DDoS protection

**For maximum security**, you can later upgrade to **Full (strict)** mode with a proper SSL certificate using Certbot.

---

## Next Steps

1. ✅ Add `APP_DOMAIN` secret in GitHub
2. ✅ Configure Cloudflare DNS A record
3. ✅ Set Cloudflare SSL to Flexible mode
4. ✅ Deploy via GitHub Actions
5. ✅ Access: `https://your-domain.com` 🎉

---

**Related Documentation:**
- [CLOUDFLARE_FIX.md](CLOUDFLARE_FIX.md) - Detailed SSL troubleshooting
- [DEVOPS.md](DEVOPS.md) - Complete DevOps guide
