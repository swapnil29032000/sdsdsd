FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build


FROM nginx:alpine

RUN adduser -D appuser \
    && mkdir -p /var/cache/nginx /var/run/nginx /run \
    && chown -R appuser:appuser /var/cache/nginx /var/run/nginx /run

USER appuser



COPY --from=builder /app/dist /usr/share/nginx/html
USER appuser
EXPOSE 80
