# Domain Configuration Guide

## Overview
The nginx configuration now supports custom domains via GitHub Secrets, allowing you to deploy to your own domain without hardcoding it in the repository.

## Setup Instructions

### 1. Add Domain Secret to GitHub

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add the following secret:
   - **Name**: `APP_DOMAIN`
   - **Value**: `nexgensis-assignment.rohitverma.social` (or your domain)

### 2. Configure DNS

Point your domain to the EC2 instance IP:

```
Type: A Record
Name: nexgensis-assignment (or @)
Value: <EC2_PUBLIC_IP>
TTL: 300
```

### 3. Deploy

The workflow will automatically:
1. Read the `APP_DOMAIN` secret
2. Replace `DOMAIN_PLACEHOLDER` in `nginx.conf` with your domain
3. Deploy the updated nginx configuration

**Fallback**: If `APP_DOMAIN` is not set, it defaults to the EC2 IP address.

## How It Works

### nginx.conf Template
```nginx
server {
    listen 80;
    server_name DOMAIN_PLACEHOLDER;
    # ... rest of config
}
```

### Workflow Logic
```yaml
# Prepare nginx.conf with domain from secrets
DOMAIN="${{ secrets.APP_DOMAIN }}"
if [ -z "$DOMAIN" ]; then
  DOMAIN="${{ needs.infrastructure.outputs.instance_ip }}"
fi

# Replace domain placeholder
sed "s|DOMAIN_PLACEHOLDER|$DOMAIN|g" nginx.conf > /tmp/nginx.conf
```

### Result
The deployed nginx.conf will have:
```nginx
server {
    listen 80;
    server_name nexgensis-assignment.rohitverma.social;
    # ... rest of config
}
```

## Testing Locally

Test the domain replacement:
```bash
sed "s|DOMAIN_PLACEHOLDER|your-domain.com|g" nginx.conf
```

## SSL/HTTPS (Future Enhancement)

To add HTTPS support:
1. Install Certbot on EC2
2. Run: `sudo certbot --nginx -d nexgensis-assignment.rohitverma.social`
3. Certbot will automatically update nginx.conf with SSL configuration

## Troubleshooting

**Issue**: Domain not resolving
- Check DNS propagation: `dig nexgensis-assignment.rohitverma.social`
- Verify A record points to correct EC2 IP

**Issue**: Nginx not using domain
- Check deployed nginx.conf: `docker exec nexgensis-gateway cat /etc/nginx/nginx.conf`
- Verify `APP_DOMAIN` secret is set in GitHub

**Issue**: 502 Bad Gateway
- Check backend/frontend containers are running: `docker ps`
- Check nginx logs: `docker logs nexgensis-gateway`
