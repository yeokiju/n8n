# n8n with persistent data support and proper start command
FROM n8nio/n8n:latest

# Switch to root for installations
USER root

# Install system dependencies including pandoc
RUN apk add --no-cache \
    curl \
    bash \
    python3 \
    make \
    g++ \
    libc6-compat \
    pandoc \
    && rm -rf /var/cache/apk/*

# Install npm packages for document processing
RUN npm install -g \
    mammoth@1.6.0 \
    officegen@0.6.5 \
    html-docx-js@0.3.1 \
    cheerio@1.0.0-rc.12 \
    axios@1.6.0 \
    lodash@4.17.21 \
    && npm cache clean --force

# Create necessary directories with proper permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

# Switch back to node user
USER node

# Set environment variables for data persistence and proxy
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=password123
ENV DB_TYPE=sqlite
ENV DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite
ENV N8N_ENCRYPTION_KEY=your-32-character-encryption-key-here
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false

# Sliplane proxy configuration
ENV N8N_PROXY_HOPS=1
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV TRUST_PROXY=true

# Node.js configuration
ENV NODE_PATH=/usr/local/lib/node_modules

# Create volume mount point for persistent data
VOLUME ["/home/node/.n8n"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

EXPOSE 5678

# Use the full path to n8n binary
CMD ["/usr/local/bin/n8n", "start"]
