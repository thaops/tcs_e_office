#!/bin/bash

echo "🔧 Fixing macOS network permissions for Flutter app..."

# Stop the app if running
echo "🛑 Stopping Flutter app..."
pkill -f "tcs_e_office" || true

# Clean build
echo "🧹 Cleaning Flutter build..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Clean macOS build specifically
echo "🧹 Cleaning macOS build..."
rm -rf macos/build/
rm -rf build/macos/

# Rebuild with new entitlements
echo "🔨 Rebuilding macOS app with new entitlements..."
flutter build macos --debug

echo "✅ Build completed with new network permissions!"
echo ""
echo "📋 Next steps:"
echo "1. Run: flutter run -d macos"
echo "2. Test Microsoft login"
echo "3. If still fails, check System Preferences > Security & Privacy > Privacy > Network"
echo ""
echo "🔍 If you see permission dialogs, click 'Allow' for network access"
