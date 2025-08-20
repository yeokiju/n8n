FROM n8nio/n8n:latest

USER root

# Alpine Linux 패키지 설치
RUN apk update && apk add --no-cache \
    curl \
    wget \
    git \
    openssh-client \
    ca-certificates \
    gcc \
    g++ \
    make \
    build-base \
    linux-headers \
    python3 \
    py3-pip \
    python3-dev \
    bash \
    vim \
    jq \
    postgresql-client \
    mysql-client \
    && rm -rf /var/cache/apk/*

# Python 패키지 설치 (--break-system-packages 플래그 사용)
RUN pip3 install --no-cache-dir --break-system-packages \
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
    xlsx

# 타임존 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

USER node
WORKDIR /home/node

CMD ["n8n"]