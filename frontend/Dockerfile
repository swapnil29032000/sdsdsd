# ---------- Build Stage ----------
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ---------- Runtime Stage ----------
FROM nginx:alpine

# Create non-root user
RUN adduser -D appuser \
    && mkdir -p /var/cache/nginx /var/run /run \
    && chown -R appuser:appuser /var/cache/nginx /var/run /run /etc/nginx /usr/share/nginx/html

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

USER appuser

EXPOSE 80

