FROM n8nio/n8n:latest

ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_HOST=leo-n8n.sliplane.app
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV WEBHOOK_URL=https://leo-n8n.sliplane.app/
ENV GENERIC_TIMEZONE=Asia/Seoul

EXPOSE 5678

VOLUME ["/home/node/.n8n"]

