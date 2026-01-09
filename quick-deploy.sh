#!/bin/bash

# =========================================
# Quick Full Deployment Script (Server)
# =========================================
# Complete deployment script for aaPanel server
# Run this ON THE SERVER: /www/wwwroot/4cbz.com/

set -e  # Exit on any error

echo "=========================================="
echo "4CBZ Complete Deployment Script"
echo "=========================================="
echo ""

# Verify we're in the right location
if [ ! -f "package.json" ] || [ ! -d "4Cbitz_frontend" ] || [ ! -d "4Cbitz_backend" ]; then
    echo "❌ Error: Not in the correct directory"
    echo "Please run this from: /www/wwwroot/4cbz.com/"
    exit 1
fi

PROJECT_ROOT=$(pwd)

# ==========================================
# 1. BACKEND DEPLOYMENT
# ==========================================
echo ""
echo "=========================================="
echo "STEP 1: Backend Deployment"
echo "=========================================="

cd "$PROJECT_ROOT/4Cbitz_backend"

# Check .env
if [ ! -f ".env" ]; then
    echo "❌ Backend .env file missing!"
    exit 1
fi

echo "📦 Installing backend dependencies..."
npm install --production

# Create logs directory
cd "$PROJECT_ROOT"
mkdir -p logs
chmod 755 logs

echo "🚀 Starting backend with PM2..."
pm2 stop 4cbz-backend 2>/dev/null || true

if [ -f "ecosystem.config.cjs" ]; then
    pm2 start ecosystem.config.cjs
else
    pm2 start 4Cbitz_backend/index.js --name 4cbz-backend
fi

pm2 save

echo "✅ Backend deployed"

# ==========================================
# 2. FRONTEND DEPLOYMENT
# ==========================================
echo ""
echo "=========================================="
echo "STEP 2: Frontend Deployment"
echo "=========================================="

cd "$PROJECT_ROOT/4Cbitz_frontend"

# Check .env
if [ ! -f ".env" ]; then
    echo "❌ Frontend .env file missing!"
    exit 1
fi

echo "Current API URL:"
grep "VITE_API_URL" .env

echo ""
read -p "Is this correct for production? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please update .env before continuing"
    exit 1
fi

echo "📦 Installing frontend dependencies..."
npm install

echo "🔨 Building frontend..."
npm run build

if [ ! -d "dist" ]; then
    echo "❌ Frontend build failed!"
    exit 1
fi

echo "✅ Frontend built successfully"

# ==========================================
# 3. SET PERMISSIONS
# ==========================================
echo ""
echo "=========================================="
echo "STEP 3: Setting Permissions"
echo "=========================================="

cd "$PROJECT_ROOT"
chown -R www:www . 2>/dev/null || echo "⚠️  Could not set ownership (you might not be root)"
chmod -R 755 .

echo "✅ Permissions set"

# ==========================================
# 4. VERIFICATION
# ==========================================
echo ""
echo "=========================================="
echo "STEP 4: Verification"
echo "=========================================="

# Check PM2
echo "📊 PM2 Status:"
pm2 list

# Test backend
echo ""
echo "🔍 Testing backend..."
sleep 2
if curl -f http://localhost:5001 > /dev/null 2>&1; then
    echo "✅ Backend is responding"
else
    echo "⚠️  Backend might not be responding. Check logs:"
    echo "   pm2 logs 4cbz-backend"
fi

# Check frontend dist
echo ""
echo "📁 Frontend dist/ size:"
du -sh "$PROJECT_ROOT/4Cbitz_frontend/dist"

# ==========================================
# COMPLETION
# ==========================================
echo ""
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo ""
echo "1. Verify Nginx configuration:"
echo "   - Root directory: /www/wwwroot/4cbz.com/4Cbitz_frontend/dist"
echo "   - API proxy: /api/* → http://localhost:5001/api/*"
echo ""
echo "2. Test Nginx config and reload:"
echo "   nginx -t && nginx -s reload"
echo ""
echo "3. Enable SSL certificate in aaPanel"
echo ""
echo "4. Test your site:"
echo "   https://4cbz.com"
echo ""
echo "Useful Commands:"
echo "  pm2 list                    - Process status"
echo "  pm2 logs 4cbz-backend       - View backend logs"
echo "  pm2 restart 4cbz-backend    - Restart backend"
echo "  nginx -t                    - Test Nginx config"
echo "  nginx -s reload             - Reload Nginx"
echo ""
echo "Logs location:"
echo "  Backend: $PROJECT_ROOT/logs/"
echo "  Nginx: /www/wwwlogs/4cbz.com.log"
echo "=========================================="
