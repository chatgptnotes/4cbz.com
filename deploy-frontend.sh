#!/bin/bash

# =========================================
# Frontend Build & Deploy Script
# =========================================
# This script builds the React frontend for production
# Run this on your LOCAL machine before uploading to server

set -e  # Exit on any error

echo "=========================================="
echo "4CBZ Frontend Production Build"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found. Are you in the project root?"
    exit 1
fi

# Navigate to frontend directory
echo "📁 Navigating to frontend directory..."
cd 4Cbitz_frontend

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found in frontend directory"
    echo "Please create .env with production values before building"
    exit 1
fi

# Display current API URL from .env
echo ""
echo "Current environment configuration:"
grep "VITE_API_URL" .env || echo "VITE_API_URL not set!"
echo ""

# Ask for confirmation
read -p "Is this the correct production API URL? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please update the .env file with correct production values:"
    echo "  VITE_API_URL=https://4cbz.com/api"
    echo "  VITE_GOOGLE_CLIENT_ID=your_production_google_client_id"
    echo "  VITE_STRIPE_PUBLISHABLE_KEY=pk_live_your_production_key"
    exit 1
fi

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Build for production
echo ""
echo "🔨 Building frontend for production..."
npm run build

# Check if build succeeded
if [ -d "dist" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📊 Build statistics:"
    du -sh dist
    echo ""
    echo "📁 Files in dist/:"
    ls -lh dist/
    echo ""
    echo "=========================================="
    echo "Next Steps:"
    echo "=========================================="
    echo "1. Upload the 'dist' folder to your server:"
    echo "   Location: /www/wwwroot/4cbz.com/4Cbitz_frontend/dist/"
    echo ""
    echo "2. Or if building on server, just run:"
    echo "   cd /www/wwwroot/4cbz.com/4Cbitz_frontend"
    echo "   npm install"
    echo "   npm run build"
    echo ""
    echo "3. Verify Nginx is configured to serve from dist/"
    echo "=========================================="
else
    echo ""
    echo "❌ Build failed! Check errors above."
    exit 1
fi
