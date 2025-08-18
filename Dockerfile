FROM n8nio/n8n:latest

USER root

# 패키지 설치
RUN apk update && apk add --no-cache \
    curl wget git bash nano vim \
    python3 py3-pip nodejs npm \
    htop jq openssh-client ca-certificates sudo

# 권한 설정
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /app && chown -R node:node /app

USER node

WORKDIR /app
COPY . .

ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

EXPOSE 5678

# 기본 n8n 시작 방식 유지
CMD ["n8n"]