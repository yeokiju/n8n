//FROM n8nio/n8n:latest

USER root

# curl 설치 상태 확인 및 기본 도구 설치
RUN which curl || apk add --no-cache curl
RUN apk add --no-cache \
    wget git bash vim python3 htop jq

USER node
WORKDIR /app
COPY . .
EXPOSE 5678