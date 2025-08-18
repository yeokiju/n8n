FROM n8nio/n8n:latest

USER root

# Docker CLI와 필요한 도구들 설치
RUN apk update && apk add --no-cache \
    curl wget git bash nano vim \
    python3 py3-pip nodejs npm \
    htop jq openssh-client ca-certificates \
    sudo docker-cli

# sudo 설정
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# node 사용자를 docker 그룹에 추가
RUN addgroup -g 999 docker || true
RUN adduser node docker

# 권한 설정
RUN mkdir -p /app && chown -R node:node /app

USER node

WORKDIR /app
COPY . .

ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

EXPOSE 5678

CMD ["n8n", "start"]