# 최소화된 n8n + curl + node Dockerfile
FROM n8nio/n8n:latest

# Switch to root for installations
USER root

# Install essential packages including curl
RUN apk add --no-cache \
    curl \
    bash \
    python3 \
    make \
    g++ \
    libc6-compat \
    procps

# Install mammoth and essential npm packages
RUN npm install -g \
    mammoth@1.6.0 \
    axios@1.6.0 \
    lodash@4.17.21 \
    && npm cache clean --force

# Ensure n8n binary is accessible
RUN which n8n || echo "n8n path: $(find / -name n8n -type f 2>/dev/null | head -1)"

# Create necessary directories with proper permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

# Switch back to node user
USER node

# Set working directory
WORKDIR /home/node

# Set environment variables for Sliplane compatibility
ENV NODE_PATH=/usr/local/lib/node_modules \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false \
    N8N_PROXY_HOPS=1 \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    TRUST_PROXY=true \
    N8N_TRUST_PROXY=true \
    NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Quick verification
RUN curl --version && node --version

EXPOSE 5678

# Use the n8n start command
CMD ["n8n", "start"]
