FROM n8nio/n8n:latest

USER root

# 패키지 저장소 업데이트 및 확장 도구 설치
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
    # Node.js 추가 도구
    nodejs-current \
    npm \
    yarn \
    # 데이터베이스 클라이언트
    postgresql-client \
    mysql-client \
    redis \
    mongodb-tools \
    # 유틸리티
    bash \
    zsh \
    vim \
    nano \
    htop \
    jq \
    yq \
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
    awk \
    # 이미지 처리
    imagemagick \
    ffmpeg \
    && rm -rf /var/cache/apk/*

# Python 패키지 설치 (데이터 처리, 웹 스크래핑, API 관련)
RUN pip3 install --no-cache-dir \
    # 웹 요청
    requests \
    urllib3 \
    httpx \
    aiohttp \
    # 데이터 처리
    pandas \
    numpy \
    openpyxl \
    xlrd \
    xlwt \
    # 웹 스크래핑
    beautifulsoup4 \
    selenium \
    scrapy \
    lxml \
    # API 도구
    fastapi \
    flask \
    # 유틸리티
    python-dotenv \
    pyyaml \
    click \
    rich

# Node.js 글로벌 패키지 설치
RUN npm install -g \
    # HTTP 클라이언트
    axios \
    node-fetch \
    got \
    # 웹 스크래핑
    puppeteer \
    playwright \
    cheerio \
    # 데이터 처리
    csv-parser \
    xlsx \
    xml2js \
    # 유틸리티
    pm2 \
    nodemon \
    dotenv-cli \
    cross-env \
    # CLI 도구
    chalk \
    commander \
    inquirer

# Chrome/Chromium 설치 (Puppeteer/Selenium용)
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

# 커스텀 스크립트 디렉토리 생성
RUN mkdir -p /scripts /data /logs && \
    chown -R node:node /scripts /data /logs

# n8n 사용자로 전환
USER node

WORKDIR /home/node

# 헬스체크 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

CMD ["n8n"]