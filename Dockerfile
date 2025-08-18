FROM n8nio/n8n:latest

# root 권한으로 전환 (패키지 설치용)
USER root

# curl 설치 확인 및 추가 도구 설치
RUN apk update && apk add --no-cache \
    curl \
    wget \
    git \
    bash \
    nano \
    vim \
    python3 \
    py3-pip \
    htop \
    jq \
    openssh-client

# 원래 사용자로 복귀
USER node

# 작업 디렉토리 설정
WORKDIR /app

# 파일 복사
COPY . .

# n8n 기본 포트 (5678) 사용
EXPOSE 5678

# n8n 시작 (기본 명령어 유지)
