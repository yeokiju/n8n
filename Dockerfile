FROM n8nio/n8n:latest

USER root

echo '#!/bin/sh' > /usr/local/bin/docker
echo 'echo "Docker is not available. Using main process execution."' >> /usr/local/bin/docker
echo 'exit 0' >> /usr/local/bin/docker
chmod +x /usr/local/bin/docker

which docker
docker

USER node
WORKDIR /home/node

EXPOSE 5678

# 시작 스크립트 실행
CMD ["/start-n8n.sh"]
