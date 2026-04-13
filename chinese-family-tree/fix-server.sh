#!/bin/bash
# Run this on your server: ssh root@8.162.0.181
# Then paste this script

echo "🔧 Fixing Chinese Family Tree Service..."
echo ""

# Stop the failing service
echo "1️⃣ Stopping service..."
systemctl stop chinese-family-tree
systemctl disable chinese-family-tree

# Check if Go is installed
echo "2️⃣ Checking Go..."
if ! command -v go &> /dev/null; then
    echo "Installing Go..."
    apt update
    apt install -y golang-go
else
    go version
fi
echo ""

# Navigate to backend
echo "3️⃣ Building backend..."
cd /opt/chinese-family-tree/backend

# Remove old binary
rm -f family-tree-api

# Download dependencies
echo "Downloading dependencies..."
go mod download

# Build (with CGO disabled for static binary)
echo "Building..."
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=amd64
go build -a -installsuffix cgo -o family-tree-api ./cmd/main.go

# Check if build succeeded
if [ -f family-tree-api ]; then
    echo "✅ Build successful!"
    ls -lh family-tree-api
    chmod +x family-tree-api
else
    echo "❌ Build failed!"
    exit 1
fi
echo ""

# Recreate service file
echo "4️⃣ Recreating systemd service..."
cat > /etc/systemd/system/chinese-family-tree.service << 'EOF'
[Unit]
Description=Chinese Family Tree API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/chinese-family-tree/backend
ExecStart=/opt/chinese-family-tree/backend/family-tree-api
Restart=always
RestartSec=5
Environment=PORT=8080
Environment=DATABASE_PATH=/opt/chinese-family-tree/backend/family_tree.db

[Install]
WantedBy=multi-user.target
EOF

# Reload and start
echo "5️⃣ Starting service..."
systemctl daemon-reload
systemctl enable chinese-family-tree
systemctl start chinese-family-tree

sleep 3

# Check status
echo "6️⃣ Service status:"
systemctl status chinese-family-tree --no-pager

echo ""
echo "7️⃣ Testing API..."
curl -v http://localhost:8080/health

echo ""
echo "========================================="
if systemctl is-active --quiet chinese-family-tree; then
    echo "✅ SUCCESS! Service is running!"
    echo ""
    echo "Access your API at: http://8.162.0.181:8080"
    echo "Health check: http://8.162.0.181:8080/health"
else
    echo "❌ Service still not running. Check logs:"
    echo "journalctl -u chinese-family-tree -f"
fi
