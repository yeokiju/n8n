FROM n8nio/n8n:latest

USER root

# Alpine에서 필요한 패키지 설치
RUN apk add --no-cache \
    sudo \
    shadow \
    bash \
    su-exec \
    libcap

# node 사용자가 없을 경우 생성 (이미 있다면 수정)
RUN if ! id -u node > /dev/null 2>&1; then \
        adduser -D -u 1000 -G root -s /bin/bash node; \
    fi

# 비밀번호 설정
RUN echo "node:nodepassword" | chpasswd

# wheel 그룹이 없으면 생성하고 node 추가
RUN addgroup -S wheel 2>/dev/null || true && \
    adduser node wheel

# sudo 설정 (Alpine에서는 특별한 설정 필요)
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel && \
    echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/wheel /etc/sudoers.d/node

# SUID 설정 (Alpine에서는 경로가 다를 수 있음)
RUN chmod u+s /bin/su || true && \
    chmod u+s /usr/bin/sudo || true

# 필요한 디렉토리 생성 및 권한 설정
RUN mkdir -p \
    /home/node \
    /home/node/.npm \
    /home/node/.config \
    /home/node/.cache \
    /home/node/.n8n \
    /var/log/node \
    /var/lib/node \
    /app

# 소유권 및 권한 설정
RUN chown -R node:node \
    /home/node \
    /var/log/node \
    /var/lib/node \
    /app && \
    chmod -R 755 /home/node /app

# n8n 특정 디렉토리 권한
RUN mkdir -p /data && \
    chown -R node:node /data && \
    chmod -R 755 /data

# capabilities 설정 (선택사항)
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/node || true

# 파일 복사 (있는 경우)
COPY --chown=node:node . /app/

# node 사용자로 전환
USER node

WORKDIR /app

# 환경 변수 설정
ENV HOME=/home/node \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    N8N_USER_FOLDER=/home/node/.n8n \
    NODE_ENV=production

EXPOSE 5678

# 진입점 설정 (필요한 경우)
# ENTRYPOINT ["n8n"]