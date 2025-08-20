FROM n8nio/n8n:latest

USER root

# 시작 스크립트 생성 (웹훅 URL 동적 설정)
RUN echo '#!/bin/bash' > /start-n8n.sh && \
    echo '' >> /start-n8n.sh && \
    echo '# 웹훅 URL이 설정되지 않았다면 기본값 사용' >> /start-n8n.sh && \
    echo 'if [ -z "$WEBHOOK_URL" ]; then' >> /start-n8n.sh && \
    echo '    export WEBHOOK_URL="http://localhost:5678/"' >> /start-n8n.sh && \
    echo '    echo "Warning: WEBHOOK_URL not set, using default: $WEBHOOK_URL"' >> /start-n8n.sh && \
    echo 'else' >> /start-n8n.sh && \
    echo '    echo "Using WEBHOOK_URL: $WEBHOOK_URL"' >> /start-n8n.sh && \
    echo 'fi' >> /start-n8n.sh && \
    echo '' >> /start-n8n.sh && \
    echo '# Editor URL이 설정되지 않았다면 WEBHOOK_URL과 동일하게 설정' >> /start-n8n.sh && \
    echo 'if [ -z "$N8N_EDITOR_BASE_URL" ]; then' >> /start-n8n.sh && \
    echo '    export N8N_EDITOR_BASE_URL="$WEBHOOK_URL"' >> /start-n8n.sh && \
    echo 'fi' >> /start-n8n.sh && \
    echo '' >> /start-n8n.sh && \
    echo '# 프로토콜 자동 감지' >> /start-n8n.sh && \
    echo 'if [[ "$WEBHOOK_URL" == https://* ]]; then' >> /start-n8n.sh && \
    echo '    export N8N_PROTOCOL="https"' >> /start-n8n.sh && \
    echo 'else' >> /start-n8n.sh && \
    echo '    export N8N_PROTOCOL="http"' >> /start-n8n.sh && \
    echo 'fi' >> /start-n8n.sh && \
    echo '' >> /start-n8n.sh && \
    echo 'echo "Configuration:"' >> /start-n8n.sh && \
    echo 'echo "  - WEBHOOK_URL: $WEBHOOK_URL"' >> /start-n8n.sh && \
    echo 'echo "  - N8N_PROTOCOL: $N8N_PROTOCOL"' >> /start-n8n.sh && \
    echo 'echo "  - N8N_EDITOR_BASE_URL: $N8N_EDITOR_BASE_URL"' >> /start-n8n.sh && \
    echo 'echo "  - N8N_HOST: $N8N_HOST"' >> /start-n8n.sh && \
    echo 'echo "  - N8N_PORT: $N8N_PORT"' >> /start-n8n.sh && \
    echo '' >> /start-n8n.sh && \
    echo '# n8n 실행' >> /start-n8n.sh && \
    echo 'exec n8n' >> /start-n8n.sh && \
    chmod +x /start-n8n.sh

# 기본 환경 변수 설정
ENV EXECUTIONS_PROCESS=main \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    NODE_ENV=production \
    GENERIC_TIMEZONE=Asia/Seoul

USER node

WORKDIR /home/node

EXPOSE 5678

# 시작 스크립트 실행
CMD ["/start-n8n.sh"]