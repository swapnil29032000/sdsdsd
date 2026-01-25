# ---------- Build stage ----------
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---------- Runtime stage ----------
FROM nginx:alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create required nginx dirs and fix permissions
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx \
    && chown -R appuser:appgroup /var/cache/nginx /var/run /var/log/nginx

# Remove default config that tries to write root-owned files
RUN rm /etc/nginx/conf.d/default.conf

# Simple nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build
COPY --from=builder /app/dist /usr/share/nginx/html

USER appuser
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
