FROM n8nio/n8n:latest

USER root

# 기본 패키지 및 sudo 설치
RUN apk add --no-cache bash sudo shadow

# node 계정에 sudo 권한 부여
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node && \
    addgroup node wheel 2>/dev/null || true

# 디렉토리 권한 설정
RUN mkdir -p /home/node/.n8n /data /app && \
    chown -R node:node /home/node/.n8n /data /app && \
    chmod -R 755 /home/node/.n8n /data /app

# 디버깅 스크립트 생성
RUN echo '#!/bin/bash' > /debug-startup.sh && \
    echo 'echo "========================================="' >> /debug-startup.sh && \
    echo 'echo "N8N DEBUG LOG - $(date)"' >> /debug-startup.sh && \
    echo 'echo "========================================="' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# 현재 사용자 정보' >> /debug-startup.sh && \
    echo 'echo "[1] Current User Info:"' >> /debug-startup.sh && \
    echo 'echo "  - User: $(whoami)"' >> /debug-startup.sh && \
    echo 'echo "  - UID: $(id -u)"' >> /debug-startup.sh && \
    echo 'echo "  - GID: $(id -g)"' >> /debug-startup.sh && \
    echo 'echo "  - Groups: $(id -G)"' >> /debug-startup.sh && \
    echo 'echo "  - Home: $HOME"' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# sudo 권한 확인' >> /debug-startup.sh && \
    echo 'echo "[2] Sudo Permission Check:"' >> /debug-startup.sh && \
    echo 'if sudo -n true 2>/dev/null; then' >> /debug-startup.sh && \
    echo '    echo "  ✓ Sudo works without password"' >> /debug-startup.sh && \
    echo '    echo "  - Sudo user: $(sudo whoami)"' >> /debug-startup.sh && \
    echo 'else' >> /debug-startup.sh && \
    echo '    echo "  ✗ Sudo requires password or not available"' >> /debug-startup.sh && \
    echo 'fi' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# 디렉토리 권한 확인' >> /debug-startup.sh && \
    echo 'echo "[3] Directory Permissions:"' >> /debug-startup.sh && \
    echo 'echo "  /home/node/.n8n:"' >> /debug-startup.sh && \
    echo '    ls -ld /home/node/.n8n 2>/dev/null | sed "s/^/    /"' >> /debug-startup.sh && \
    echo 'echo "  /data:"' >> /debug-startup.sh && \
    echo '    ls -ld /data 2>/dev/null | sed "s/^/    /"' >> /debug-startup.sh && \
    echo 'echo "  /app:"' >> /debug-startup.sh && \
    echo '    ls -ld /app 2>/dev/null | sed "s/^/    /"' >> /debug-startup.sh && \
    echo 'echo "  /home/node:"' >> /debug-startup.sh && \
    echo '    ls -ld /home/node 2>/dev/null | sed "s/^/    /"' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# 쓰기 권한 테스트' >> /debug-startup.sh && \
    echo 'echo "[4] Write Permission Test:"' >> /debug-startup.sh && \
    echo 'for dir in /home/node/.n8n /data /app; do' >> /debug-startup.sh && \
    echo '    if [ -d "$dir" ]; then' >> /debug-startup.sh && \
    echo '        if touch "$dir/test_write_$$" 2>/dev/null; then' >> /debug-startup.sh && \
    echo '            echo "  ✓ Write permission OK: $dir"' >> /debug-startup.sh && \
    echo '            rm -f "$dir/test_write_$$"' >> /debug-startup.sh && \
    echo '        else' >> /debug-startup.sh && \
    echo '            echo "  ✗ No write permission: $dir"' >> /debug-startup.sh && \
    echo '        fi' >> /debug-startup.sh && \
    echo '    else' >> /debug-startup.sh && \
    echo '        echo "  ! Directory not found: $dir"' >> /debug-startup.sh && \
    echo '    fi' >> /debug-startup.sh && \
    echo 'done' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# 환경 변수 확인' >> /debug-startup.sh && \
    echo 'echo "[5] Environment Variables:"' >> /debug-startup.sh && \
    echo 'echo "  - N8N_HOST: $N8N_HOST"' >> /debug-startup.sh && \
    echo 'echo "  - N8N_PORT: $N8N_PORT"' >> /debug-startup.sh && \
    echo 'echo "  - NODE_ENV: $NODE_ENV"' >> /debug-startup.sh && \
    echo 'echo "  - EXECUTIONS_PROCESS: $EXECUTIONS_PROCESS"' >> /debug-startup.sh && \
    echo 'echo "  - GENERIC_TIMEZONE: $GENERIC_TIMEZONE"' >> /debug-startup.sh && \
    echo 'echo "  - N8N_USER_FOLDER: ${N8N_USER_FOLDER:-/home/node/.n8n}"' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# Node.js 버전 확인' >> /debug-startup.sh && \
    echo 'echo "[6] Node.js Version:"' >> /debug-startup.sh && \
    echo 'echo "  - Node: $(node --version 2>/dev/null || echo "not found")"' >> /debug-startup.sh && \
    echo 'echo "  - NPM: $(npm --version 2>/dev/null || echo "not found")"' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# n8n 실행 파일 확인' >> /debug-startup.sh && \
    echo 'echo "[7] n8n Executable Check:"' >> /debug-startup.sh && \
    echo 'if which n8n >/dev/null 2>&1; then' >> /debug-startup.sh && \
    echo '    echo "  ✓ n8n found at: $(which n8n)"' >> /debug-startup.sh && \
    echo '    ls -l $(which n8n) | sed "s/^/    /"' >> /debug-startup.sh && \
    echo 'else' >> /debug-startup.sh && \
    echo '    echo "  ✗ n8n executable not found in PATH"' >> /debug-startup.sh && \
    echo 'fi' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# 프로세스 리스트 (선택사항)' >> /debug-startup.sh && \
    echo 'echo "[8] Process Check:"' >> /debug-startup.sh && \
    echo 'echo "  - Current processes: $(ps aux | wc -l) running"' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# 디스크 공간 확인' >> /debug-startup.sh && \
    echo 'echo "[9] Disk Space:"' >> /debug-startup.sh && \
    echo 'df -h / | tail -1 | awk "{print \"  - Root: \" \$5 \" used (\" \$4 \" available)\"}"' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo 'echo "========================================="' >> /debug-startup.sh && \
    echo 'echo "Starting n8n..."' >> /debug-startup.sh && \
    echo 'echo "========================================="' >> /debug-startup.sh && \
    echo '' >> /debug-startup.sh && \
    echo '# n8n 실행' >> /debug-startup.sh && \
    echo 'exec n8n' >> /debug-startup.sh && \
    chmod +x /debug-startup.sh

# 환경 변수로 Docker 실행 모드 비활성화
ENV EXECUTIONS_PROCESS=main \
    N8N_HOST=0.0.0.0 \
    N8N_PORT=5678 \
    NODE_ENV=production \
    GENERIC_TIMEZONE=Asia/Seoul

USER node

WORKDIR /home/node

EXPOSE 5678

# 디버깅 스크립트로 시작
CMD ["/debug-startup.sh"]