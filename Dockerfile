FROM alpine:latest

RUN apk update && \
    apk add --no-cache curl unzip ca-certificates && \
    mkdir -p /tmp/app /usr/local/share/web-worker && \
    curl -L -H "Cache-Control: no-cache" -o /tmp/app/pkg.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/app/pkg.zip -d /tmp/app && \
    mv /tmp/app/xray /usr/local/bin/web-worker && \
    mv /tmp/app/*.dat /usr/local/share/web-worker/ && \
    chmod +x /usr/local/bin/web-worker && \
    rm -rf /tmp/app /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
