# n8n with persistent data support and startup script
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

# Set working directory
WORKDIR /home/node

# Create volume mount point for persistent data
VOLUME ["/home/node/.n8n"]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

EXPOSE 5678

# Use the startup script
CMD ["/usr/local/bin/n8n"]
