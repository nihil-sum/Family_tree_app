#!/bin/bash

# Chinese Family Tree - Frontend Deployment Script
# Run this on your server: ssh root@8.162.0.181

set -e

echo "🚀 Chinese Family Tree - Frontend Deployment"
echo "=============================================="
echo ""

# Install dependencies
echo "1️⃣ Installing dependencies..."
apt update
apt install -y curl git unzip xz-utils zip libglu1-mesa wget

# Install Flutter
echo "2️⃣ Installing Flutter..."
cd /opt
if [ ! -d "flutter" ]; then
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PATH:/opt/flutter/bin"

# Flutter doctor
echo "3️⃣ Running flutter doctor..."
/opt/flutter/bin/flutter doctor

# Copy frontend files
echo "4️⃣ Copying frontend files..."
if [ ! -d "/opt/chinese-family-tree/frontend" ]; then
    mkdir -p /opt/chinese-family-tree
fi

# You need to copy frontend files first
# rsync -avz /path/to/local/frontend/ root@8.162.0.181:/opt/chinese-family-tree/frontend/

cd /opt/chinese-family-tree/frontend

# Update API URL
echo "5️⃣ Configuring API URL..."
sed -i "s|http://8.162.0.181:8080|http://8.162.0.181:8080|g" lib/main.dart

# Get dependencies
echo "6️⃣ Getting dependencies..."
/opt/flutter/bin/flutter pub get

# Build web
echo "7️⃣ Building for web..."
/opt/flutter/bin/flutter build web --release

# Install nginx
echo "8️⃣ Installing nginx..."
apt install -y nginx

# Configure nginx
echo "9️⃣ Configuring nginx..."
cat > /etc/nginx/sites-available/chinese-family-tree << 'EOF'
server {
    listen 80;
    server_name 8.162.0.181;
    
    root /opt/chinese-family-tree/frontend/build/web;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Proxy API requests to backend
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /health {
        proxy_pass http://localhost:8080;
    }
}
EOF

# Enable site
ln -sf /etc/nginx/sites-available/chinese-family-tree /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and restart nginx
echo "🔟 Starting nginx..."
nginx -t
systemctl enable nginx
systemctl restart nginx

echo ""
echo "=============================================="
echo "✅ Frontend Deployment Complete!"
echo ""
echo "🌐 Access your app at: http://8.162.0.181"
echo ""
echo "Useful commands:"
echo "  systemctl status nginx"
echo "  nginx -t"
echo "  /opt/flutter/bin/flutter --version"
echo ""
