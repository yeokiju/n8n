FROM n8nio/n8n:latest

USER root

# 필요한 패키지 설치
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git

# 권한 설정
RUN mkdir -p /home/node/.n8n && \
    chmod 700 /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

USER node

EXPOSE 5678

ENTRYPOINT ["tini", "--", "n8n"]