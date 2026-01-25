# -------- Build stage --------
FROM node:20-alpine AS builder
WORKDIR /app

ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# -------- Runtime stage --------
FROM nginx:alpine

# Create non-root user
RUN adduser -D appuser

# Create and fix permissions for nginx directories
RUN mkdir -p \
    /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp \
    /var/run \
    /run \
    /usr/share/nginx/html \
 && chown -R appuser:appuser /var/cache/nginx /var/run /run /usr/share/nginx/html

# Copy built frontend
COPY --from=builder /app/dist /usr/share/nginx/html

USER appuser

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
