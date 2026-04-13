#!/bin/bash

# Chinese Family Tree - Deployment Script
# Builds and deploys the application to production

set -e

SERVER_HOST="8.162.0.181"
SERVER_USER="root"
REMOTE_PATH="/opt/chinese-family-tree"

echo "🚀 Chinese Family Tree - Deployment"
echo "==================================="
echo "Server: $SERVER_USER@$SERVER_HOST"
echo "Target: $REMOTE_PATH"
echo ""

# Check if SSH connection works
echo "🔍 Testing SSH connection..."
ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_HOST "echo '✓ Connected'" || {
    echo "❌ Cannot connect to server. Please check connection and credentials."
    exit 1
}

echo ""
echo "🔨 Building and deploying backend..."

# Build and deploy backend
ssh $SERVER_USER@$SERVER_HOST "
    cd $REMOTE_PATH/backend
    
    echo '📦 Installing dependencies...'
    go mod tidy
    
    echo '🏗️ Building application...'
    export CGO_ENABLED=0
    export GOOS=linux
    export GOARCH=amd64
    go build -a -installsuffix cgo -o family-tree-api ./cmd/main.go
    
    echo '✅ Backend built successfully'
"

echo ""
echo "📱 Building and deploying frontend..."

# Build and deploy frontend
ssh $SERVER_USER@$SERVER_HOST "
    echo '📦 Installing Flutter if needed...'
    if ! command -v flutter &> /dev/null; then
        echo 'Installing Flutter...'
        cd /opt
        git clone https://github.com/flutter/flutter.git -b stable --depth 1
        export PATH='\$PATH:/opt/flutter/bin'
    fi
    
    export PATH='\$PATH:/opt/flutter/bin'
    
    cd $REMOTE_PATH/frontend
    
    echo '🧩 Getting dependencies...'
    flutter pub get
    
    echo '🏗️ Building web app...'
    flutter clean
    flutter build web --release
    
    echo '✅ Frontend built successfully'
"

echo ""
echo "⚙️ Configuring services..."

# Configure and restart services
ssh $SERVER_USER@$SERVER_HOST "
    # Install nginx if needed
    if ! command -v nginx &> /dev/null; then
        apt update
        apt install -y nginx
    fi
    
    # Create nginx configuration
    cat > /etc/nginx/sites-available/chinese-family-tree << 'EOF'
server {
    listen 80;
    server_name $SERVER_HOST;
    
    root $REMOTE_PATH/frontend/build/web;
    index index.html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /health {
        proxy_pass http://127.0.0.1:8080;
    }
}
EOF
    
    # Enable site
    ln -sf /etc/nginx/sites-available/chinese-family-tree /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Create systemd service for backend
    cat > /etc/systemd/system/chinese-family-tree.service << 'EOF'
[Unit]
Description=Chinese Family Tree API
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$REMOTE_PATH/backend
ExecStart=$REMOTE_PATH/backend/family-tree-api
Restart=always
RestartSec=5
Environment=PORT=8080
Environment=DATABASE_PATH=$REMOTE_PATH/backend/family_tree.db

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd and restart services
    systemctl daemon-reload
    systemctl enable chinese-family-tree
    systemctl restart chinese-family-tree
    systemctl restart nginx
    
    echo '✅ Services configured and restarted'
"

echo ""
echo "🔍 Running post-deployment checks..."

# Run health checks
ssh $SERVER_USER@$SERVER_HOST "
    echo '🏥 Checking backend health...'
    curl -s http://localhost:8080/health || echo '❌ Backend health check failed'
    
    echo '🌐 Checking frontend accessibility...'
    curl -s http://localhost/ || echo '❌ Frontend check failed'
    
    echo '📊 Checking service status...'
    systemctl status chinese-family-tree --no-pager
    systemctl status nginx --no-pager
"

echo ""
echo "==================================="
echo "✅ DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo ""
echo "🌍 Your Chinese Family Tree app is live at:"
echo "   Frontend: http://$SERVER_HOST"
echo "   Backend:  http://$SERVER_HOST:8080"
echo "   Health:   http://$SERVER_HOST/health"
echo ""
echo "🛠️ Useful commands:"
echo "   Check backend logs: journalctl -u chinese-family-tree -f"
echo "   Check nginx logs:  tail -f /var/log/nginx/error.log"
echo "   Restart services:  systemctl restart chinese-family-tree nginx"
echo ""