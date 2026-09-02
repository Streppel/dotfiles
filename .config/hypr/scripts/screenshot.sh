#!/usr/bin/env bash
# Region or full capture → Tensaku (Enter: clipboard, Ctrl+S: ~/Pictures).
set -euo pipefail

if ! command -v tensaku >/dev/null 2>&1; then
  notify-send -u critical "Screenshot" "tensaku não está instalado. No terminal: yay -S tensaku" 2>/dev/null || true
  exit 1
fi

mode="${1:-region}"

case "$mode" in
  region)
    geom="$(slurp)" || exit 0
    grim -g "$geom" -t ppm - | tensaku --filename -
    ;;
  full)
    grim -t ppm - | tensaku --filename -
    ;;
  *)
    echo "usage: $0 region|full" >&2
    exit 2
    ;;
esac
