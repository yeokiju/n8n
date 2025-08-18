FROM n8nio/n8n:latest

USER root

# 기본 패키지만 설치
RUN apk add --no-cache bash

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