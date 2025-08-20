# 가장 간단한 n8n + mammoth.js Dockerfile
FROM n8nio/n8n:latest

# Switch to root for installations
USER root

# Install system dependencies
RUN apk add --no-cache python3 make g++ libc6-compat

# Install packages globally to avoid directory naming issues
RUN npm install -g mammoth@1.6.0 xlsx@0.18.5 csv-parser@3.0.0

# Switch back to node user
USER node

# Set environment variables
ENV NODE_PATH=/usr/local/lib/node_modules
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_LOG_LEVEL=warn

# Verify installation
RUN node -e "try { console.log('mammoth version:', require('mammoth/package.json').version); } catch(e) { console.error('mammoth failed:', e.message); }"

EXPOSE 5678
