# Use official n8n image
FROM n8nio/n8n:latest

# Switch to root for installations and fixes
USER root

# Install system dependencies including pandoc and additional tools
RUN apk add --no-cache \
    curl \
    bash \
    python3 \
    py3-pip \
    make \
    g++ \
    gcc \
    libc6-compat \
    pandoc \
    pkill \
    git \
    openssh \
    ca-certificates \
    openssl \
    wget \
    zip \
    unzip \
    jq \
    postgresql-client \
    mysql-client \
    redis \
    imagemagick \
    graphicsmagick \
    ffmpeg \
    tesseract-ocr \
    tesseract-ocr-data-eng \
    tesseract-ocr-data-kor \
    poppler-utils \
    && rm -rf /var/cache/apk/*

# Install Python packages for data processing
RUN pip3 install --no-cache-dir \
    pandas \
    numpy \
    requests \
    beautifulsoup4 \
    pypdf2 \
    python-docx \
    openpyxl \
    xlrd \
    python-dateutil

# Install npm packages for document processing and additional utilities
RUN npm install -g \
    mammoth@1.6.0 \
    officegen@0.6.5 \
    html-docx-js@0.3.1 \
    cheerio@1.0.0-rc.12 \
    axios@1.6.0 \
    lodash@4.17.21 \
    pdf-parse@1.1.1 \
    csv-parser@3.0.0 \
    xlsx@0.18.5 \
    node-html-parser@6.1.5 \
    sharp@0.32.0 \
    jsonwebtoken@9.0.0 \
    bcryptjs@2.4.3 \
    uuid@9.0.0 \
    moment@2.29.4 \
    moment-timezone@0.5.43 \
    dotenv@16.0.3 \
    node-fetch@3.3.1 \
    form-data@4.0.0 \
    multer@1.4.5-lts.1 \
    archiver@5.3.1 \
    decompress@4.2.1 \
    && npm cache clean --force

# Create startup script to handle permissions and cleanup
RUN cat > /docker-entrypoint.sh << 'EOF'
#!/bin/sh
set -e

# Kill any zombie n8n processes
pkill -f n8n || true
sleep 1

# Fix permissions for .n8n directory
if [ -d /home/node/.n8n ]; then
    chown -R node:node /home/node/.n8n
    chmod 700 /home/node/.n8n
    
    # Fix config file permissions if it exists
    if [ -f /home/node/.n8n/config ]; then
        chmod 600 /home/node/.n8n/config
    fi
fi

# Create .n8n directory if it doesn't exist
if [ ! -d /home/node/.n8n ]; then
    mkdir -p /home/node/.n8n
    chown -R node:node /home/node/.n8n
    chmod 700 /home/node/.n8n
fi

# Create workflows directory for custom workflows
mkdir -p /home/node/.n8n/workflows
chown -R node:node /home/node/.n8n/workflows

# Create custom nodes directory
mkdir -p /home/node/.n8n/nodes
chown -R node:node /home/node/.n8n/nodes

# Create backup directory
mkdir -p /home/node/.n8n/backups
chown -R node:node /home/node/.n8n/backups

# Set Python path for n8n to use Python nodes
export PYTHON_PATH=/usr/bin/python3
export NODE_PATH=/usr/local/lib/node_modules:$NODE_PATH

# Switch to node user and start n8n
exec su-exec node n8n start
EOF

# Install su-exec for proper user switching
RUN apk add --no-cache su-exec

# Make script executable
RUN chmod +x /docker-entrypoint.sh

# Set environment variables
ENV N8N_TRUST_PROXY=true \
    NODE_ENV=production \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    N8N_PROTOCOL=http \
    N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
    EXECJS_RUNTIME=Disabled \
    PYTHON_PATH=/usr/bin/python3 \
    NODE_PATH=/usr/local/lib/node_modules \
    N8N_DEFAULT_BINARY_DATA_MODE=filesystem \
    N8N_PAYLOAD_SIZE_MAX=16 \
    N8N_METRICS=false \
    N8N_LOG_LEVEL=info \
    N8N_VERSION_NOTIFICATIONS_ENABLED=false

# Create volume mount point
VOLUME ["/home/node/.n8n"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

EXPOSE 5678

# Use the custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
