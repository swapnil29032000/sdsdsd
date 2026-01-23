# Stage 1: Build environment
FROM node:22-slim AS builder

WORKDIR /app

# Install dependencies
# We copy package files first to leverage Docker cache
COPY package*.json ./
RUN npm install

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Runtime environment (Node-based, No Nginx)
FROM node:22-slim

WORKDIR /app

# Install 'serve' globally as root
# This ensures the binary is available without runtime downloads
RUN npm install -g serve

# Create a non-root user correctly for Debian-based image
# -m creates the home directory (/home/nodejs)
RUN useradd -m nodejs

# Copy only the static build assets
COPY --from=builder /app/dist ./dist

# Ensure the non-root user owns the app directory
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Set environment variables for npm/node tools
ENV HOME=/home/nodejs
ENV npm_config_cache=/home/nodejs/.npm

# Expose the application port
EXPOSE 5173

# Run the application using 'serve'
# -s flag handles Single Page Application (SPA) routing
CMD ["serve", "-s", "dist", "-l", "5173"]
