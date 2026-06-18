#!/usr/bin/env bash
#
# run.sh — Build, cài và chạy SmartTime trên iOS Simulator.
# Dùng: ./run.sh [tên-simulator]   (mặc định: iPhone 17)
#
set -euo pipefail

PROJECT="SmartTime.xcodeproj"
SCHEME="SmartTime"
BUNDLE_ID="com.nguyensinh.SmartTime"
DEVICE="${1:-iPhone 17}"

echo "▶︎ Build ($DEVICE)..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  -configuration Debug build | tail -1

echo "▶︎ Khởi động simulator..."
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator

APP=$(find ~/Library/Developer/Xcode/DerivedData/SmartTime-*/Build/Products/Debug-iphonesimulator \
  -name "$SCHEME.app" 2>/dev/null | head -1)

if [[ -z "$APP" ]]; then
  echo "✗ Không tìm thấy $SCHEME.app sau khi build." >&2
  exit 1
fi

echo "▶︎ Cài + chạy app..."
xcrun simctl install "$DEVICE" "$APP"
xcrun simctl launch "$DEVICE" "$BUNDLE_ID"

echo "✓ Đã chạy SmartTime trên \"$DEVICE\"."
