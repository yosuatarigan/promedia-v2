#!/usr/bin/env bash
# Pemasangan awal layanan Promedia di VPS bersama (sekali saja).
# Dijalankan DI VPS dengan sudo:  sudo bash setup-vps.sh
# Hanya membuat/mengubah: user `promedia`, /opt/promedia, unit promedia-api.service.
set -euo pipefail

NODE_VERSION="v22.23.3"
BASE=/opt/promedia

# 1. User sistem tanpa login & tanpa home
if ! id promedia >/dev/null 2>&1; then
  useradd --system --no-create-home --shell /usr/sbin/nologin promedia
fi

# 2. Folder
install -d -o promedia -g promedia -m 750 "$BASE"
install -d -o promedia -g promedia -m 700 "$BASE/app" "$BASE/secrets" "$BASE/.npm"

# 3. Node pribadi (node sistem tidak disentuh), checksum diverifikasi
if [ ! -x "$BASE/node/bin/node" ] || [ "$("$BASE/node/bin/node" -v)" != "$NODE_VERSION" ]; then
  tmp=$(mktemp -d)
  file="node-$NODE_VERSION-linux-x64.tar.xz"
  curl -fsSL -o "$tmp/$file" "https://nodejs.org/dist/$NODE_VERSION/$file"
  curl -fsSL -o "$tmp/SHASUMS256.txt" "https://nodejs.org/dist/$NODE_VERSION/SHASUMS256.txt"
  (cd "$tmp" && grep " $file\$" SHASUMS256.txt | sha256sum -c -)
  rm -rf "$BASE/node"
  install -d -m 755 "$BASE/node"
  tar -xJf "$tmp/$file" -C "$BASE/node" --strip-components=1
  chown -R promedia:promedia "$BASE/node"
  rm -rf "$tmp"
fi

# 4. Konfigurasi (tanpa rahasia; kunci service account di secrets/)
if [ ! -f "$BASE/.env" ]; then
  cat > "$BASE/.env" <<'ENV'
NODE_ENV=production
FIREBASE_PROJECT_ID=app-jarak-penentu
HOST=127.0.0.1
PORT=8750
CORS_ORIGINS=https://promedia-v2.vercel.app,http://localhost:8080
GOOGLE_APPLICATION_CREDENTIALS=/opt/promedia/secrets/service-account.json
ENV
  chown promedia:promedia "$BASE/.env"
  chmod 600 "$BASE/.env"
fi

echo "OK: $("$BASE/node/bin/node" -v), user promedia, $BASE siap"
