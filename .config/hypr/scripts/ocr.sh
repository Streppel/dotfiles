#!/usr/bin/env bash
# Region capture → Tesseract → clipboard.
set -euo pipefail

if ! command -v tesseract >/dev/null 2>&1; then
  notify-send -u critical "OCR" "tesseract não está instalado. No terminal: sudo pacman -S tesseract tesseract-data-eng tesseract-data-por" 2>/dev/null || true
  exit 1
fi

geom="$(slurp)" || exit 0

langs="eng"
if tesseract --list-langs 2>/dev/null | grep -qx por; then
  langs="por+eng"
fi

text="$(grim -g "$geom" - | tesseract stdin stdout -l "$langs" 2>/dev/null || true)"
text="${text%"${text##*[![:space:]]}"}"

if [[ -z "$text" ]]; then
  notify-send -t 2500 "OCR" "Nenhum texto encontrado" 2>/dev/null || true
  exit 0
fi

printf '%s' "$text" | wl-copy
notify-send -t 2500 "OCR" "$text" 2>/dev/null || true
