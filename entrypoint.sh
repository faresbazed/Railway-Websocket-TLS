#!/bin/sh

# Default fallback values if not set in Railway Variables
PORT=${PORT:-8080}
UUID=${UUID:-"de04add9-5c68-8bab-950c-08cd5320df18"}
WS_PATH=${WS_PATH:-"/api/v1/sync"}

mkdir -p /etc/webapp

cat <<EOF > /etc/webapp/app.json
{
  "log": {
    "loglevel": "none"
  },
  "inbounds": [
    {
      "port": ${PORT},
      "listen": "0.0.0.0",
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

export XRAY_LOCATION_ASSET="/usr/local/share/web-worker/"
exec /usr/local/bin/web-worker run -c /etc/webapp/app.json
