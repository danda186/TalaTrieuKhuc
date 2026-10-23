#!/usr/bin/env bash
# Dựng thư mục dự án gồm 4 phần từ repo này:
#   BE/         -> sẽ thành repo GitHub talatrieukhuc-be (engine luật + server)
#   Mobile/     -> sẽ thành repo GitHub talatrieukhuc-mobile (app Flutter)
#   Documents/  -> tài liệu (không dùng git)
#   Designs/    -> thiết kế giao diện (không dùng git)
#
# Dùng:  bash tools/tach-du-an.sh [thư mục đích]   (mặc định: ~/TalaTrieuKhuc)
# Script chỉ sao chép file, không tạo repo git và không đẩy gì lên GitHub.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-$HOME/TalaTrieuKhuc}"

for part in BE Mobile Documents Designs; do
  if [ -e "$DEST/$part" ] && [ -n "$(ls -A "$DEST/$part" 2>/dev/null)" ]; then
    echo "Dừng: $DEST/$part đã có dữ liệu, không ghi đè." >&2
    exit 1
  fi
done

mkdir -p "$DEST/BE/packages" "$DEST/Mobile" "$DEST/Documents" "$DEST/Designs"

cp -R "$SRC/packages/ta_la_engine" "$DEST/BE/packages/"
rm -rf "$DEST/BE/packages/ta_la_engine/.dart_tool"

cp -R "$SRC/docs/." "$DEST/Documents/"
cp -R "$SRC/designs/." "$DEST/Designs/"

echo "Xong: $DEST"
echo "  BE/packages/ta_la_engine  (engine luật, 52 test)"
echo "  Mobile/                   (trống, sẽ tạo app Flutter)"
echo "  Documents/                (luật chơi, kiến trúc online, hướng dẫn)"
echo "  Designs/                  (mã nguồn các màn giao diện)"
