FROM n8nio/n8n:latest

USER root

# 패키지 설치
RUN apk update && apk add --no-cache \
    curl \
    wget \
    git \
    bash \
    python3 \
    py3-pip \
    jq \
    vim \
    && rm -rf /var/cache/apk/*

# Python 패키지 설치
RUN pip3 install --no-cache-dir --break-system-packages \
    requests \
    pandas \
    beautifulsoup4

# 테스트 스크립트만 생성 (실행은 수동으로)
RUN mkdir -p /scripts
RUN cat > /scripts/curl-test.sh << 'EOF'
#!/bin/bash
echo "=== Network Test ==="
curl -s -o /dev/null -w "Naver: %{http_code}\n" https://www.naver.com
curl -s -o /dev/null -w "Google: %{http_code}\n" https://www.google.com
echo "=== Test Complete ==="
EOF
RUN chmod +x /scripts/curl-test.sh

# 타임존 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

USER node
WORKDIR /home/node

# 기본 n8n 실행 명령어 사용 (가장 안전)
CMD ["n8n", "start"]