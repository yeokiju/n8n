# N8N without volume - data stored in container
FROM n8nio/n8n:latest

# Switch to root for installations
USER root

# Install essential packages
RUN apk add --no-cache \
    curl \
    bash \
    python3 \
    make \
    g++ \
    gcc \
    libc6-compat \
    procps \
    git \
    openssh \
    wget \
    zip \
    unzip \
    jq \
    postgresql15-client \
    mysql-client \
    redis \
    imagemagick \
    ffmpeg \
    poppler-utils

# Install npm packages
RUN npm install -g \
    mammoth@1.6.0 \
    officegen@0.6.5 \
    html-docx-js@0.3.1 \
    pdf-parse@1.1.1 \
    cheerio@1.0.0-rc.12 \
    axios@1.6.0 \
    lodash@4.17.21 \
    csv-parser@3.0.0 \
    xlsx@0.18.5 \
    moment@2.29.4 \
    uuid@9.0.0 \
    jsonwebtoken@9.0.0 \
    bcryptjs@2.4.3 \
    && npm cache clean --force

# Create .n8n directory with proper permissions
RUN mkdir -p /home/node/.n8n && \
    mkdir -p /home/node/.n8n/nodes && \
    mkdir -p /home/node/.n8n/workflows && \
    mkdir -p /home/node/.n8n/backups && \
    chown -R node:node /home/node && \
    chmod -R 755 /home/node/.n8n

# Switch to node user
USER node

# Set working directory
WORKDIR /home/node

# Environment variables - NO VOLUME
ENV NODE_PATH=/usr/local/lib/node_modules \
    N8N_USER_FOLDER=/home/node/.n8n \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false \
    N8N_PROXY_HOPS=1 \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    N8N_TRUST_PROXY=true \
    NODE_ENV=production \
    N8N_PROTOCOL=http \
    N8N_DEFAULT_BINARY_DATA_MODE=filesystem \
    N8N_PAYLOAD_SIZE_MAX=16 \
    N8N_METRICS=false \
    N8N_LOG_LEVEL=info \
    DB_TYPE=sqlite \
    DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite \
    DB_SQLITE_POOL_SIZE=2 \
    N8N_RUNNERS_ENABLED=true \
    NODE_NO_WARNINGS=1

# NO VOLUME DECLARATION - data stored in container layer

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

EXPOSE 5678
