FROM golang:1.17-alpine AS ProxyBuilder

RUN apk add --no-cache git

RUN go install github.com/acheong08/ChatGPT-Proxy-V4@latest

FROM python:3.10-alpine

# 安装 nodejs 和 pnpm
RUN apk add --no-cache nodejs npm
RUN npm install -g pnpm

# 构建前端
COPY frontend /app/frontend
WORKDIR /app/frontend
RUN pnpm install
RUN pnpm run build

# 安装 poetry
RUN apk add --no-cache curl
RUN curl -sSL https://install.python-poetry.org | python -

# 配置后端
COPY backend /app/backend
COPY config.yaml /app/backend/api/config/config.yaml
WORKDIR /app/backend
RUN poetry install

COPY Caddyfile /app/Caddyfile
COPY frontend/dist /app/dist
COPY --from=ProxyBuilder /go/bin/ChatGPT-Proxy-V4 /app/backend/ChatGPT-Proxy-V4
COPY backend /app/backend

# 安装 caddy
RUN apk add --no-cache caddy

WORKDIR /app

EXPOSE 80

COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh; mkdir /data
CMD ["/app/startup.sh"]
