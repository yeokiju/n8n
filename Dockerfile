FROM n8nio/n8n:latest

USER root

# Alpine Linux 패키지 설치 (호환되는 패키지명 사용)
RUN apk update && apk add --no-cache \
    # 기본 도구
    curl \
    wget \
    git \
    openssh-client \
    ca-certificates \
    # 개발 도구
    gcc \
    g++ \
    make \
    cmake \
    build-base \
    linux-headers \
    # Python 3
    python3 \
    py3-pip \
    python3-dev \
    # Node.js (이미 n8n 이미지에 포함됨)
    # nodejs \
    # npm \
    yarn \
    # 데이터베이스 클라이언트
    postgresql-client \
    mysql-client \
    redis \
    # mongodb-tools는 Alpine에서 직접 지원 안됨
    # 유틸리티
    bash \
    zsh \
    vim \
    nano \
    htop \
    jq \
    # yq는 community 레포에서 설치
    tree \
    ncurses \
    # 압축 도구
    zip \
    unzip \
    tar \
    gzip \
    bzip2 \
    xz \
    # 네트워크 도구
    iputils \
    net-tools \
    bind-tools \
    tcpdump \
    nmap \
    netcat-openbsd \
    # 파일 처리
    file \
    findutils \
    grep \
    sed \
    # awk는 기본 포함
    # 이미지 처리
    imagemagick \
    ffmpeg \
    && rm -rf /var/cache/apk/*

# Python 패키지 설치
RUN pip3 install --no-cache-dir \
    requests \
    pandas \
    numpy \
    openpyxl \
    beautifulsoup4 \
    selenium \
    python-dotenv \
    pyyaml \
    httpx

# npm 글로벌 패키지 설치
RUN npm install -g \
    axios \
    puppeteer \
    cheerio \
    node-fetch \
    dotenv \
    csv-parser \
    xlsx \
    pm2

# Chrome/Chromium 설치 (Puppeteer용)
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    && rm -rf /var/cache/apk/*

# Puppeteer 설정
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# 타임존 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 디렉토리 생성 및 권한 설정
RUN mkdir -p /scripts /data /logs && \
    chown -R node:node /scripts /data /logs

USER node
WORKDIR /home/node

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

CMD ["n8n"]