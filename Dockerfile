# n8n with mammoth.js support
FROM n8nio/n8n:latest

# Switch to root user to install packages
USER root

# Update package list and install dependencies
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    make \
    g++ \
    git

# Create directory for custom node modules
RUN mkdir -p /usr/local/lib/node_modules

# Install mammoth globally
RUN npm install -g mammoth

# Install additional useful packages for document processing
RUN npm install -g \
    mammoth \
    docx-parser \
    pdf-parse \
    xlsx \
    csv-parser \
    cheerio

# Create a custom node_modules directory that n8n can access
RUN mkdir -p /home/node/.n8n/custom_modules
WORKDIR /home/node/.n8n/custom_modules

# Install packages locally for n8n Code nodes
RUN npm init -y && npm install \
    mammoth \
    docx-parser \
    pdf-parse \
    xlsx \
    csv-parser \
    cheerio \
    jsdom

# Set proper permissions
RUN chown -R node:node /home/node/.n8n
RUN chmod -R 755 /home/node/.n8n

# Switch back to node user
USER node

# Set environment variables
ENV NODE_PATH=/home/node/.n8n/custom_modules/node_modules:/usr/local/lib/node_modules
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom_modules

# Expose the n8n port
EXPOSE 5678
