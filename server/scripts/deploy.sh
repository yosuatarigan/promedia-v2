#!/usr/bin/env bash
# Deploy kode layanan Promedia ke VPS. Jalankan dari folder server/:
#   ./scripts/deploy.sh
# Prasyarat: setup-vps.sh sudah pernah dijalankan (lihat docs/vps-server.md).
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="${PROMEDIA_VPS_HOST:-ubuntu@43.173.34.20}"
KEY="${PROMEDIA_VPS_KEY:-$HOME/.ssh/flashkuota_proxy}"
SSH=(ssh -o BatchMode=yes -i "$KEY" "$HOST")

STAGE=$(mktemp -d)
tar -czf "$STAGE/promedia-release.tgz" src package.json package-lock.json systemd
scp -q -i "$KEY" "$STAGE/promedia-release.tgz" "$HOST:/tmp/promedia-release.tgz"
rm -rf "$STAGE"

"${SSH[@]}" 'set -e
BASE=/opt/promedia
sudo install -d -o promedia -g promedia -m 700 $BASE/app.new
sudo tar -xzf /tmp/promedia-release.tgz -C $BASE/app.new
sudo chown -R promedia:promedia $BASE/app.new
rm -f /tmp/promedia-release.tgz
sudo -u promedia env PATH=$BASE/node/bin:/usr/bin:/bin npm_config_cache=$BASE/.npm \
  sh -c "cd $BASE/app.new && npm ci --omit=dev --no-audit --no-fund --loglevel=error"
sudo install -m 644 $BASE/app.new/systemd/promedia-api.service /etc/systemd/system/promedia-api.service
sudo systemctl daemon-reload
sudo systemctl stop promedia-api 2>/dev/null || true
sudo rm -rf $BASE/app.old
if sudo test -d $BASE/app; then sudo mv $BASE/app $BASE/app.old; fi
sudo mv $BASE/app.new $BASE/app
if sudo test -f $BASE/secrets/service-account.json; then
  sudo systemctl enable --now promedia-api
  sudo systemctl restart promedia-api
  sleep 3
  systemctl is-active promedia-api
  curl -fsS http://127.0.0.1:8750/health; echo
else
  echo "Kunci service account belum ada: service belum dijalankan."
fi
sudo rm -rf $BASE/app.old'
