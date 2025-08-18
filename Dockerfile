FROM n8nio/n8n:latest

USER root

# 기본 패키지 및 sudo 설치
RUN apk add --no-cache bash sudo shadow

# node 계정에 sudo 권한 부여
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node && \
    addgroup node wheel 2>/dev/null || true

# 디렉토리 권한 설정
RUN mkdir -p /home/node/.n8n /data && \
    chown -R node:node /home/node/.n8n /data && \
    chmod -R 755 /home/node/.n8n /data

# 환경 변수로 Docker 실행 모드 비활성화
ENV EXECUTIONS_PROCESS=main \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    NODE_ENV=production \
    GENERIC_TIMEZONE=Asia/Seoul

USER node

WORKDIR /home/node

EXPOSE 5678

# n8n 직접 실행
CMD ["n8n"]