FROM n8nio/n8n:latest

USER root

# 권한 관련 패키지만 설치
RUN apk add --no-cache sudo shadow util-linux busybox-suid

# node 사용자 강화 설정
RUN echo "node:nodepassword" | chpasswd
RUN usermod -aG wheel node
RUN usermod -s /bin/bash node

# SUID 비트 설정
RUN chmod 4755 /bin/su
RUN chmod 4755 /usr/bin/sudo
RUN chmod 4755 /bin/busybox

# sudoers 파일 설정
RUN echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node
RUN echo "Defaults !requiretty" >> /etc/sudoers.d/node
RUN chmod 440 /etc/sudoers.d/node

# 디렉토리 완전 소유권 설정
RUN mkdir -p /app /home/node/.npm /home/node/.config /home/node/.cache
RUN chown -R node:node /app /home/node
RUN chmod -R 755 /app /home/node

# 추가 권한 디렉토리
RUN mkdir -p /var/log/node /var/lib/node
RUN chown -R node:node /var/log/node /var/lib/node

USER node

WORKDIR /app
COPY --chown=node:node . .

# node 사용자 환경 설정
ENV HOME=/home/node
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678

EXPOSE 5678

