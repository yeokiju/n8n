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
gcc \
libc6-compat \
pandoc \
procps \
git \
openssh \
ca-certificates \
openssl \
wget \
zip \
unzip \
jq \
libc6-compat

# Install mammoth and essential npm packages
RUN npm install -g \
axios@1.6.0 \
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
jsonwebtoken@9.0.0 \
bcryptjs@2.4.3 \
uuid@9.0.0 \
moment@2.29.4 \
moment-timezone@0.5.43 \
dotenv@16.0.3 \
lodash@4.17.21

# Switch back to node user
USER node

# Set environment variables for Sliplane compatibility
ENV NODE_PATH=/usr/local/lib/node_modules
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_PROXY_HOPS=1
ENV N8N_HOST=0.0.0.0
ENV TRUST_PROXY=true

# Quick verification
RUN curl --version && node --version

EXPOSE 5678
CMD ["n8n", "start"]
