# N8N without volume - data stored in container
FROM n8nio/n8n:latest

# Switch to root for installations
USER root

# Add testing repository for LibreOffice and install essential packages
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update

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

# Install LibreOffice and required dependencies
RUN apk add --no-cache \
    libreoffice \
    openjdk11-jre \
    font-noto \
    font-noto-cjk \
    font-noto-emoji \
    ttf-dejavu \
    ttf-liberation \
    ttf-linux-libertine \
    && rm -rf /var/cache/apk/*

# Install npm packages
RUN npm install -g \
    mammoth@1.6.0 \
    officegen@0.6.5 \
    html-docx-js@0.3.1 \
    docx2html@1.4.0 \
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
    mkdir -p /home/node/.n8n/temp && \
    chown -R node:node /home/node && \
    chmod -R 755 /home/node/.n8n

# Create a wrapper script for LibreOffice conversions
RUN cat > /usr/local/bin/convert-office.sh << 'EOF'
#!/bin/bash
# LibreOffice conversion wrapper
# Usage: convert-office.sh input_file output_format output_dir

INPUT_FILE="$1"
OUTPUT_FORMAT="$2"
OUTPUT_DIR="${3:-/tmp}"

if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FORMAT" ]; then
    echo "Usage: convert-office.sh <input_file> <output_format> [output_dir]"
    echo "Formats: pdf, html, docx, xlsx, pptx, txt, csv, jpg, png"
    exit 1
fi

# Run LibreOffice in headless mode
soffice --headless --convert-to "$OUTPUT_FORMAT" --outdir "$OUTPUT_DIR" "$INPUT_FILE"
EOF

RUN chmod +x /usr/local/bin/convert-office.sh

# Verify LibreOffice installation
RUN soffice --version

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
    NODE_NO_WARNINGS=1 \
    LIBREOFFICE_PATH=/usr/bin/soffice

# NO VOLUME DECLARATION - data stored in container layer

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

EXPOSE 5678
