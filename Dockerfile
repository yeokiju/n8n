FROM n8nio/n8n:latest

# root 권한으로 패키지 설치
USER root

# 시스템 업데이트 및 개발 도구 설치
RUN apk update && apk add --no-cache \
    curl \
    wget \
    git \
    bash \
    nano \
    vim \
    python3 \
    py3-pip \
    nodejs \
    npm \
    htop \
    jq \
    openssh-client \
    ca-certificates \
    sudo

# sudo 설정 - node 사용자에게 sudo 권한 부여
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 추가 Python 패키지 (선택사항)
//RUN pip3 install requests pandas

# node 사용자가 /app 디렉토리에 쓰기 권한 갖도록 설정
RUN mkdir -p /app && chown -R node:node /app

# 임시 디렉토리 권한 설정
RUN chmod 777 /tmp

# 원래 사용자로 복귀
USER node

WORKDIR /app
COPY . .

# 환경변수 설정
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

EXPOSE 5678
