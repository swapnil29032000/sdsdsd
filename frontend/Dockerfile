# -------- Build Stage --------
    FROM node:20-alpine AS builder

    WORKDIR /app
    
    COPY package*.json ./
    RUN npm install
    
    COPY . .
    RUN npm run build
    
    # -------- Runtime Stage --------
    FROM nginx:alpine
    
    # Create non-root user
    RUN adduser -D reactuser
    
    COPY --from=builder /app/dist /usr/share/nginx/html
    
    RUN chown -R reactuser:reactuser /usr/share/nginx/html
    USER reactuser
    
    EXPOSE 80
    
    CMD ["nginx", "-g", "daemon off;"]
    