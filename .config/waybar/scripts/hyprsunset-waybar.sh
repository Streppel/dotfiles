#!/usr/bin/env bash
set -u

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
paused_file="$runtime_dir/waybar-hyprsunset-paused"

if [[ "${1:-}" == "toggle" ]]; then
	if [[ -e "$paused_file" ]]; then
		rm -f "$paused_file"
		hyprctl hyprsunset reset >/dev/null 2>&1
	else
		: > "$paused_file"
		hyprctl hyprsunset identity true >/dev/null 2>&1
	fi
	exit 0
fi

identity="$(hyprctl hyprsunset identity get 2>/dev/null || true)"

if [[ -e "$paused_file" ]]; then
	if [[ "$identity" != "true" ]]; then
		hyprctl hyprsunset identity true >/dev/null 2>&1 || true
	fi
	printf '{"text":"","tooltip":"Hyprsunset pausado. Clique para retomar o perfil automático.","class":"paused"}\n'
elif [[ "$identity" == "true" ]]; then
	printf '{"text":"","tooltip":"Perfil automático neutro. Clique para pausar manualmente.","class":"active"}\n'
else
	temperature="$(hyprctl hyprsunset temperature 2>/dev/null | tr -cd '0-9' | head -c 5)"
	printf '{"text":"","tooltip":"Filtro ativo: %s K. Clique para pausar manualmente.","class":"active"}\n' "${temperature:-?}"
fi
