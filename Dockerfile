# Full-featured n8n Dockerfile with all packages
FROM n8nio/n8n:latest

# Switch to root for installations
USER root

# Install system packages - Step 1: Core tools
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
    ca-certificates \
    openssl

# Install system packages - Step 2: Utilities
RUN apk add --no-cache \
    wget \
    zip \
    unzip \
    jq \
    nano \
    vim

# Install system packages - Step 3: Database clients
RUN apk add --no-cache \
    postgresql15-client \
    mysql-client \
    redis

# Install system packages - Step 4: Media processing
RUN apk add --no-cache \
    imagemagick \
    ffmpeg \
    poppler-utils \
    graphicsmagick || true

# Install system packages - Step 5: Additional tools
RUN apk add --no-cache \
    pandoc \
    tesseract-ocr || true

# Install Python pip if not available
RUN python3 -m ensurepip 2>/dev/null || true && \
    pip3 install --upgrade pip 2>/dev/null || true

# Install basic Python packages (optional, can fail gracefully)
RUN pip3 install --no-cache-dir --break-system-packages \
    requests \
    beautifulsoup4 \
    python-dateutil 2>/dev/null || true

# Install npm packages - Group 1: Document processing
RUN npm install -g \
    mammoth@1.6.0 \
    officegen@0.6.5 \
    html-docx-js@0.3.1 \
    pdf-parse@1.1.1 \
    && npm cache clean --force

# Install npm packages - Group 2: Data processing
RUN npm install -g \
    cheerio@1.0.0-rc.12 \
    axios@1.6.0 \
    lodash@4.17.21 \
    csv-parser@3.0.0 \
    xlsx@0.18.5 \
    && npm cache clean --force

# Install npm packages - Group 3: Utilities
RUN npm install -g \
    moment@2.29.4 \
    moment-timezone@0.5.43 \
    uuid@9.0.0 \
    jsonwebtoken@9.0.0 \
    bcryptjs@2.4.3 \
    && npm cache clean --force

# Install npm packages - Group 4: HTTP and file handling
RUN npm install -g \
    node-fetch@3.3.1 \
    form-data@4.0.0 \
    dotenv@16.0.3 \
    multer@1.4.5-lts.1 \
    archiver@5.3.1 \
    && npm cache clean --force

# Install npm packages - Group 5: Additional utilities
RUN npm install -g \
    node-html-parser@6.1.5 \
    xml2js@0.6.0 \
    js-yaml@4.1.0 \
    && npm cache clean --force

# Create necessary directories with proper permissions
RUN mkdir -p /home/node/.n8n \
    /home/node/.n8n/nodes \
    /home/node/.n8n/workflows \
    /home/node/.n8n/backups \
    /home/node/.n8n/custom \
    && chown -R node:node /home/node/.n8n

# Create a startup script for better control
RUN cat > /start.sh << 'EOF'
#!/bin/sh
# Ensure proper permissions
chown -R node:node /home/node/.n8n 2>/dev/null || true
chmod 755 /home/node/.n8n 2>/dev/null || true

# Kill any existing n8n processes
pkill -f n8n 2>/dev/null || true
sleep 1

# Start n8n
exec n8n start
EOF

RUN chmod +x /start.sh

# Switch back to node user
USER node

# Set working directory
WORKDIR /home/node

# Set comprehensive environment variables
ENV NODE_PATH=/usr/local/lib/node_modules \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false \
    N8N_PROXY_HOPS=1 \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    TRUST_PROXY=true \
    N8N_TRUST_PROXY=true \
    NODE_ENV=production \
    N8N_PROTOCOL=http \
    N8N_DEFAULT_BINARY_DATA_MODE=filesystem \
    N8N_PAYLOAD_SIZE_MAX=16 \
    N8N_METRICS=false \
    N8N_LOG_LEVEL=info \
    PYTHON_PATH=/usr/bin/python3 \
    N8N_PUSH_BACKEND=websocket

# Health check with longer start period
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Verify installations
RUN echo "=== Installed Packages ===" && \
    echo "Node version: $(node --version)" && \
    echo "NPM version: $(npm --version)" && \
    echo "Python version: $(python3 --version)" && \
    echo "Curl version: $(curl --version | head -1)" && \
    echo "=== NPM Global Packages ===" && \
    npm list -g --depth=0 || true

EXPOSE 5678
