FROM n8nio/n8n:latest

USER root

# npm 글로벌 패키지 설치
RUN npm install -g \
    axios \
    puppeteer \
    cheerio \
    node-fetch \
    dotenv \
    csv-parser \
    xlsx \
	mammoth \
	csv-parser


USER node
WORKDIR /home/node

