# 최소화된 n8n + curl + node Dockerfile
FROM n8nio/n8n:latest

# Switch to root for installations
USER root

# Install essential packages including curl
RUN apk add --no-cache --no-cache pandoc

RUN apt-get update && apt-get install -y pandoc

RUN npm install -g \
    mammoth@1.6.0 \
    officegen@0.6.5 \
    html-docx-js@0.3.1 \
    cheerio@1.0.0-rc.12

# Switch back to node user
USER node

EXPOSE 5678
