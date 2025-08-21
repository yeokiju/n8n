FROM n8nio/n8n:latest
USER root
RUN apk add --no-cache curl pandoc
RUN npm install -g mammoth || echo "continuing..."
USER node
EXPOSE 5678
CMD ["sh", "-c", "n8n start || node /usr/local/lib/node_modules/n8n/bin/n8n start"]
