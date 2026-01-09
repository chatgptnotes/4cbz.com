#!/bin/bash

# =========================================
# Backend Deployment Script for Server
# =========================================
# Run this script ON THE SERVER after uploading files
# Location: /www/wwwroot/4cbz.com/

set -e  # Exit on any error

echo "=========================================="
echo "4CBZ Backend Deployment"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -d "4Cbitz_backend" ]; then
    echo "❌ Error: 4Cbitz_backend directory not found"
    echo "Make sure you're in /www/wwwroot/4cbz.com/"
    exit 1
fi

# Navigate to backend directory
cd 4Cbitz_backend

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create .env file with production environment variables"
    echo "See .env.production.template for required variables"
    exit 1
fi

# Validate critical environment variables
echo "🔍 Validating environment variables..."
required_vars=("SUPABASE_URL" "SUPABASE_ANON_KEY" "JWT_SECRET" "STRIPE_SECRET_KEY" "FRONTEND_URL")
missing_vars=()

for var in "${required_vars[@]}"; do
    if ! grep -q "^${var}=" .env; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "❌ Missing required environment variables:"
    printf '   - %s\n' "${missing_vars[@]}"
    exit 1
fi

# Check for placeholder JWT secrets
if grep -q "your_jwt_secret_key_here_change_this" .env; then
    echo "❌ Error: JWT_SECRET still has placeholder value!"
    echo "Generate a strong secret with: openssl rand -base64 64"
    exit 1
fi

echo "✅ Environment variables validated"
echo ""

# Install dependencies
echo "📦 Installing production dependencies..."
npm install --production

# Create logs directory if it doesn't exist
echo "📁 Setting up logs directory..."
cd ..
mkdir -p logs
chown www:www logs 2>/dev/null || true
chmod 755 logs

echo ""
echo "🚀 Starting backend with PM2..."

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 not found. Installing PM2..."
    npm install -g pm2
fi

# Stop existing process if running
pm2 stop 4cbz-backend 2>/dev/null || true

# Start with ecosystem config
if [ -f "ecosystem.config.cjs" ]; then
    echo "Using ecosystem.config.cjs..."
    pm2 start ecosystem.config.cjs
else
    echo "Using direct PM2 start..."
    pm2 start 4Cbitz_backend/index.js --name 4cbz-backend -i 1 --mode cluster
fi

# Save PM2 process list
pm2 save

# Show status
echo ""
echo "📊 PM2 Status:"
pm2 list

echo ""
echo "📋 Recent logs:"
pm2 logs 4cbz-backend --lines 20 --nostream

echo ""
echo "=========================================="
echo "✅ Backend Deployment Complete!"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  pm2 list                    - Show all processes"
echo "  pm2 logs 4cbz-backend       - View logs"
echo "  pm2 restart 4cbz-backend    - Restart backend"
echo "  pm2 monit                   - Real-time monitoring"
echo ""
echo "Test backend:"
echo "  curl http://localhost:5001/api/health"
echo "  curl https://4cbz.com/api/health"
echo "=========================================="
