FROM n8nio/n8n:latest
# 필요한 도구들 설치
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
    openssh-client
# 작업 디렉토리 설정
WORKDIR /app
# 파일 복사
COPY . .
# 포트 노출
EXPOSE 3000
# HTTP 서버 시작 (헬스체크용)
CMD ["python3", "-m", "http.server", "3000"]