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
    libc6-compat

# Install mammoth and essential npm packages
RUN npm install -g \
    mammoth@1.6.0 \
    axios@1.6.0 \
    lodash@4.17.21

# Switch back to node user
USER node

# Quick verification
RUN curl --version && node --version

EXPOSE 5678
