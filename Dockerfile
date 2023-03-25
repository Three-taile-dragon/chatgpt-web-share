FROM golang:1.17-alpine AS ProxyBuilder

# 安装 git
RUN apk add --no-cache git

# 安装 ChatGPT-Proxy-V4
RUN go install github.com/acheong08/ChatGPT-Proxy-V4@latest

# 从 $GOPATH/bin 中复制二进制文件
COPY --from=ProxyBuilder /go/bin/ChatGPT-Proxy-V4 /app/backend/ChatGPT-Proxy-V4

RUN CGO_ENABLED=0 go build -a -installsuffix cgo -o ChatGPT-Proxy-V4 .

FROM python:3.10-alpine

ARG PIP_CACHE_DIR=/pip_cache

RUN mkdir -p /app/backend

RUN apk add --no-cache caddy

COPY backend/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY Caddyfile /app/Caddyfile
COPY backend /app/backend
COPY frontend/dist /app/dist
COPY --from=ProxyBuilder /app/ChatGPT-Proxy-V4/ChatGPT-Proxy-V4 /app/backend/ChatGPT-Proxy-V4

WORKDIR /app

EXPOSE 80

COPY startup.sh /app/startup.sh
RUN chmod +x /app/startup.sh; mkdir /data
CMD ["/app/startup.sh"]
