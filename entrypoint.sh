#!/bin/sh

# Render defaults to 10000; Cloud Run / Northflank / Railway default to 8080
PORT=${PORT:-8080}
UUID=${UUID:-"de04add9-5c68-8bab-950c-08cd5320df18"}
WS_PATH=${WS_PATH:-"/api/v1/sync"}
INTERNAL_PORT=40000

mkdir -p /etc/webapp

# 1. Generate internal Xray configuration (listens only on localhost)
cat <<EOF > /etc/webapp/app.json
{
  "log": {
    "loglevel": "none"
  },
  "inbounds": [
    {
      "port": ${INTERNAL_PORT},
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "level": 0
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "${WS_PATH}"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

# 2. Generate Caddyfile (serves 200 OK health check on / and proxies WS_PATH to Xray)
cat <<EOF > /etc/webapp/Caddyfile
:${PORT} {
    log {
        output discard
    }
    handle ${WS_PATH} {
        reverse_proxy 127.0.0.1:${INTERNAL_PORT}
    }
    handle {
        header Content-Type "application/json"
        respond "{\"status\":\"ok\",\"service\":\"sync-worker\",\"uptime\":\"active\"}" 200
    }
}
EOF

# 3. Start obfuscated Xray in the background and run Caddy in the foreground
export XRAY_LOCATION_ASSET="/usr/local/share/web-worker/"
/usr/local/bin/web-worker run -c /etc/webapp/app.json &
exec caddy run --config /etc/webapp/Caddyfile --adapter caddyfile
