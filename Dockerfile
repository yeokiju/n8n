FROM n8nio/n8n:latest

USER root

# 필요한 패키지 설치
RUN apk update && apk add --no-cache \
    curl wget git bash nano vim \
    python3 py3-pip nodejs npm \
    htop jq openssh-client ca-certificates \
    sudo shadow util-linux busybox-suid

# SUID 권한 설정
RUN chmod u+s /bin/su
RUN chmod u+s /usr/bin/sudo
RUN chmod u+s /bin/busybox

# sudo 설정
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "Defaults !requiretty" >> /etc/sudoers

# 그룹 설정
RUN adduser node wheel

# 디렉토리 권한
RUN mkdir -p /app && chown -R node:node /app

USER node

WORKDIR /app
COPY . .

ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

EXPOSE 5678

CMD ["n8n", "start"]