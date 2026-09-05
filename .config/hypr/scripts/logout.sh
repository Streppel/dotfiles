#!/usr/bin/env bash
# Confirm before ending the Hyprland session (Super+M).
set -euo pipefail

logout_now() {
  if command -v hyprshutdown >/dev/null 2>&1; then
    exec hyprshutdown
  fi
  # Hyprland 0.55+ Lua: `dispatch exit` is invalid; must pass the dispatcher object.
  hyprctl dispatch 'hl.dsp.exit()'
}

if [[ "${1:-}" != --prompt ]]; then
  if hyprctl clients -j 2>/dev/null | grep -q '"class": "logout-confirm"'; then
    hyprctl dispatch "hl.dsp.focus({ window = 'class:^logout-confirm$' })" >/dev/null 2>&1 || true
    exit 0
  fi

  exec kitty \
    --class logout-confirm \
    --title "Logout" \
    -o remember_window_size=no \
    -o initial_window_width=460 \
    -o initial_window_height=220 \
    -o hide_window_decorations=yes \
    -o window_padding_width=22 \
    -o background="#0a0a0f" \
    -o foreground="#dcd7ba" \
    -o background_opacity=0.92 \
    -o confirm_os_window_close=0 \
    -o enable_audio_bell=no \
    -o visual_bell_duration=0 \
    -o font_family="JetBrainsMono Nerd Font" \
    -o font_size=13 \
    -o cursor_trail=0 \
    "$0" --prompt
fi

cleanup() {
  printf '\e[?25h\e[0m\e[?1000l\e[?1006l'
  stty echo 2>/dev/null || true
}
trap cleanup EXIT
stty -echo
printf '\e[?25l\e[?1006h\e[?1000h'

BG=$'\e[48;2;10;10;15m'
FG=$'\e[38;2;220;215;186m'
MUTED=$'\e[38;2;114;113;105m'
MAUVE=$'\e[38;2;149;127;184m'
PILL=$'\e[48;2;42;42;55m'
PILL_FG=$'\e[38;2;200;192;147m'
SEL_CANCEL=$'\e[48;2;118;148;106m\e[38;2;10;10;15m'
SEL_LOGOUT=$'\e[48;2;232;36;36m\e[38;2;10;10;15m'
RST=$'\e[0m'"$BG"

BTN_ROW=1
CANCEL_X1=1 CANCEL_X2=1
LOGOUT_X1=1 LOGOUT_X2=1

fill() { printf '%s\e[K\n' "$1"; }

draw() {
  local sel=$1
  local cols lines pad_top cancel_btn logout_btn pad
  cols=$(tput cols 2>/dev/null || echo 44)
  lines=$(tput lines 2>/dev/null || echo 12)
  ((cols < 36)) && cols=36

  if ((sel == 0)); then
    cancel_btn="${SEL_CANCEL}  cancel  ${RST}"
    logout_btn="${PILL}${PILL_FG}  log out  ${RST}"
  else
    cancel_btn="${PILL}${PILL_FG}  cancel  ${RST}"
    logout_btn="${SEL_LOGOUT}  log out  ${RST}"
  fi

  local row1 row2 row3 row4
  row1="${MAUVE}session${FG}"
  row2="${FG}Log out of Hyprland?${RST}"
  row3="${cancel_btn}   ${logout_btn}"
  row4="${MUTED}← → · enter · esc · click${RST}"

  center() {
    local text=$1 visible=$2
    local p=$(( (cols - visible) / 2 ))
    ((p < 0)) && p=0
    printf '%*s%s' "$p" "" "$text"
  }

  pad_top=$(( (lines - 7) / 2 ))
  ((pad_top < 1)) && pad_top=1
  pad=$(( (cols - 24) / 2 ))
  ((pad < 0)) && pad=0
  # 1-based cell coords for mouse hits (cancel 10 cols, gap 3, log out 11)
  BTN_ROW=$((pad_top + 5))
  CANCEL_X1=$((pad + 1))
  CANCEL_X2=$((pad + 10))
  LOGOUT_X1=$((pad + 14))
  LOGOUT_X2=$((pad + 24))

  printf '%s\e[H\e[2J' "$BG$FG"
  local i
  for ((i = 0; i < pad_top; i++)); do
    fill ""
  done
  fill "$(center "$row1" 7)"
  fill ""
  fill "$(center "$row2" 21)"
  fill ""
  fill "$(center "$row3" 24)"
  fill ""
  fill "$(center "$row4" 26)"
  for ((i = pad_top + 7; i < lines; i++)); do
    fill ""
  done
}

hit_button() {
  local x=$1 y=$2
  ((y != BTN_ROW)) && return 1
  if ((x >= CANCEL_X1 && x <= CANCEL_X2)); then
    echo cancel
  elif ((x >= LOGOUT_X1 && x <= LOGOUT_X2)); then
    echo logout
  else
    return 1
  fi
}

selected=0
draw "$selected"

read_key() {
  local k c seq
  IFS= read -rsn1 k || return 1
  if [[ $k != $'\e' ]]; then
    printf '%s' "$k"
    return 0
  fi
  IFS= read -rsn1 -t 0.01 c || { printf '\e'; return 0; }
  if [[ $c != '[' ]]; then
    printf '\e%s' "$c"
    return 0
  fi
  seq='['
  while IFS= read -rsn1 c; do
    seq+="$c"
    [[ $c == [[:alpha:]~Mm] ]] && break
  done
  printf '\e%s' "$seq"
}

while key=$(read_key); do
  case "$key" in
    $'\e'|q|Q|n|N)
      exit 0
      ;;
    $'\e[D'|h|H|$'\t')
      selected=$((1 - selected))
      draw "$selected"
      ;;
    $'\e[C'|l|L)
      selected=$((1 - selected))
      draw "$selected"
      ;;
    y|Y)
      logout_now
      ;;
    ''|$'\n'|$'\r'|' ')
      if ((selected == 1)); then
        logout_now
      else
        exit 0
      fi
      ;;
    $'\e['\<*)
      # SGR mouse: \e[<btn;x;yM (press) / m (release)
      if [[ $key =~ ^$'\e''\[<0\;([0-9]+)\;([0-9]+)M$' ]]; then
        hit=$(hit_button "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" || true)
        case "$hit" in
          cancel) exit 0 ;;
          logout) logout_now ;;
        esac
      fi
      ;;
  esac
done
