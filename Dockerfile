FROM golang:1.18-alpine AS ProxyBuilder

RUN apk add --no-cache git

RUN go install github.com/acheong08/ChatGPT-Proxy-V4@latest

# 新的构建阶段：构建前端
FROM node:16-alpine AS FrontendBuilder

RUN npm install -g pnpm

COPY frontend /app/frontend
WORKDIR /app/frontend
RUN pnpm install
RUN pnpm run build

FROM python:3.10-alpine

RUN apk add --no-cache curl
RUN curl -sSL https://install.python-poetry.org | python -

COPY backend /app/backend
COPY config.yaml /app/backend/api/config/config.yaml
WORKDIR /app/backend
RUN poetry install

COPY Caddyfile /app/Caddyfile

# 从 FrontendBuilder 阶段复制生成的 dist 目录
COPY --from=FrontendBuilder /app/frontend/dist /app/dist

COPY --from=ProxyBuilder /go/bin/ChatGPT-Proxy-V4 /app/backend/ChatGPT-Proxy-V4
COPY backend /app/backend

RUN apk add --no-cache caddy

WORKDIR /app

EXPOSE 80

COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh; mkdir /data
CMD ["/app/startup.sh"]
