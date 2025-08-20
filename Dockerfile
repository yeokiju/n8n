# 단순화된 n8n + mammoth.js Dockerfile
FROM n8nio/n8n:latest

# Switch to root for package installation
USER root

# Install system dependencies for native modules
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    libc6-compat

# Switch back to node user
USER node

# Set working directory
WORKDIR /home/node/.n8n

# Install only essential packages to avoid dependency conflicts
RUN npm init -y && npm install \
    mammoth@1.6.0 \
    xlsx@0.18.5 \
    csv-parser@3.0.0

# Set environment variables
ENV NODE_PATH=/home/node/.n8n/node_modules
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_LOG_LEVEL=warn

# Verify installation
RUN node -e "console.log('mammoth:', require('mammoth') ? 'OK' : 'FAILED')"

EXPOSE 5678
CMD ["n8n", "start"]