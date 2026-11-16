#!/usr/bin/env bash
set -e

echo "=================================================="
echo "    Zesho Backend Diagnostic & Startup Tool       "
echo "=================================================="

# 1. Ensure PostgreSQL is active
if command -v systemctl &> /dev/null; then
  if systemctl is-active --quiet postgresql; then
    echo "[✓] PostgreSQL service is active."
  else
    echo "[!] PostgreSQL is not running. Starting..."
    systemctl start postgresql || echo "[!] Could not start postgresql via systemctl"
  fi
fi

# 2. Check Node & Dependencies
echo "[*] Checking Node version: $(node -v)"
echo "[*] Ensuring production dependencies..."
npm install --omit=dev --no-audit --no-fund

# 3. Run Database Migrations
echo "[*] Running database migrations..."
node src/db/setup.js || echo "[!] Database setup had warnings (continuing)..."

# 4. Start / Restart with PM2
if command -v pm2 &> /dev/null; then
  echo "[*] Restarting application via PM2..."
  pm2 delete zesho-backend 2>/dev/null || true
  pm2 start ecosystem.config.cjs
  pm2 save
  echo "[✓] PM2 process list:"
  pm2 list
else
  echo "[*] PM2 not detected globally. Installing pm2..."
  npm install -g pm2 || true
  if command -v pm2 &> /dev/null; then
    pm2 delete zesho-backend 2>/dev/null || true
    pm2 start ecosystem.config.cjs
    pm2 save
    pm2 list
  else
    echo "[*] Running background node process..."
    pkill -f "node src/index.js" || true
    nohup node src/index.js > /var/log/zesho-backend.log 2>&1 &
  fi
fi

# 5. Local verification check
sleep 3
echo "=================================================="
echo "           Local Verification Check               "
echo "=================================================="
curl -s -i http://127.0.0.1:3000/api/v1/health || echo "[!] Failed to connect to port 3000"
echo ""
echo "Done! If 200 OK is shown above, https://zesho.tech is now online."
