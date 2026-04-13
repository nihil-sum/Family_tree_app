#!/bin/bash

# Chinese Family Tree - Push to Server Script
# Copies updated source code to the server

set -e

SERVER_HOST="8.162.0.181"
SERVER_USER="root"
REMOTE_PATH="/opt/chinese-family-tree"

echo "🚀 Chinese Family Tree - Push to Server"
echo "======================================="
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
echo "📤 Pushing updated source code..."

# Push backend files
echo "  → Pushing backend files..."
rsync -avz --delete \
    --exclude='.git' \
    --exclude='*.db' \
    --exclude='build/' \
    --exclude='node_modules/' \
    --exclude='.dart_tool/' \
    --exclude='.vscode/' \
    --exclude='.idea/' \
    --exclude='*.log' \
    ./backend/ $SERVER_USER@$SERVER_HOST:$REMOTE_PATH/backend/

# Push frontend files
echo "  → Pushing frontend files..."
rsync -avz --delete \
    --exclude='.git' \
    --exclude='build/' \
    --exclude='.dart_tool/' \
    --exclude='.pub/' \
    --exclude='*.lock' \
    --exclude='.vscode/' \
    --exclude='.idea/' \
    --exclude='*.log' \
    --exclude='ios/' \
    --exclude='android/' \
    --exclude='web/' \
    ./frontend/ $SERVER_USER@$SERVER_HOST:$REMOTE_PATH/frontend/

echo ""
echo "✅ Push completed successfully!"
echo ""
echo "💡 Next steps:"
echo "   1. Run deployment script: ./deploy.sh"
echo "   2. Or run manual deployment commands"
echo ""