#!/bin/bash

# Run this script ON YOUR SERVER via SSH
# ssh root@8.162.0.181
# Then paste/run this script

echo "🔍 Chinese Family Tree - Troubleshooting"
echo "========================================="
echo ""

# 1. Check if Go is installed
echo "1️⃣ Checking Go installation..."
if command -v go &> /dev/null; then
    go version
else
    echo "❌ Go is NOT installed!"
    echo "   Install with: apt update && apt install -y golang-go"
fi
echo ""

# 2. Check if service exists
echo "2️⃣ Checking systemd service..."
if systemctl is-active --quiet chinese-family-tree; then
    echo "✅ Service is RUNNING"
    systemctl status chinese-family-tree --no-pager -l
elif systemctl is-enabled --quiet chinese-family-tree; then
    echo "⚠️  Service is enabled but NOT running"
    systemctl status chinese-family-tree --no-pager -l
else
    echo "❌ Service is NOT installed"
fi
echo ""

# 3. Check service logs
echo "3️⃣ Recent service logs:"
journalctl -u chinese-family-tree -n 20 --no-pager
echo ""

# 4. Check if port 8080 is listening
echo "4️⃣ Checking port 8080..."
if command -v netstat &> /dev/null; then
    netstat -tlnp | grep 8080
elif command -v ss &> /dev/null; then
    ss -tlnp | grep 8080
else
    echo "⚠️  Neither netstat nor ss available"
fi
echo ""

# 5. Check if binary exists
echo "5️⃣ Checking backend binary..."
if [ -f /opt/chinese-family-tree/backend/family-tree-api ]; then
    echo "✅ Binary exists"
    ls -lh /opt/chinese-family-tree/backend/family-tree-api
else
    echo "❌ Binary NOT found!"
fi
echo ""

# 6. Check firewall
echo "6️⃣ Checking firewall..."
if command -v ufw &> /dev/null; then
    ufw status
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --list-all
else
    echo "ℹ️  No firewall tool detected (ufw/firewalld)"
fi
echo ""

# 7. Try to start manually
echo "7️⃣ Trying to start manually..."
cd /opt/chinese-family-tree/backend
if [ -f ./family-tree-api ]; then
    echo "Starting backend..."
    PORT=8080 DATABASE_PATH=/opt/chinese-family-tree/backend/family_tree.db ./family-tree-api &
    sleep 2
    curl -v http://localhost:8080/health
    kill %1 2>/dev/null
else
    echo "❌ Cannot start - binary missing"
fi
echo ""

echo "========================================="
echo "📋 Quick Fix Commands:"
echo ""
echo "# If Go is missing:"
echo "apt update && apt install -y golang-go"
echo ""
echo "# If service failed:"
echo "cd /opt/chinese-family-tree/backend"
echo "go mod download"
echo "go build -o family-tree-api ./cmd/main.go"
echo "systemctl restart chinese-family-tree"
echo ""
echo "# Check logs:"
echo "journalctl -u chinese-family-tree -f"
echo ""
