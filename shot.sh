#!/usr/bin/env bash
#
# shot.sh — Chụp màn hình simulator đang chạy.
# Dùng: ./shot.sh [tên-simulator] [đường-dẫn-ảnh]
#
set -euo pipefail

DEVICE="${1:-iPhone 17}"
OUT="${2:-smarttime-shot.png}"

xcrun simctl io "$DEVICE" screenshot "$OUT"
echo "✓ Đã lưu ảnh: $OUT"
open "$OUT"
