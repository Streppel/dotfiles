#!/usr/bin/env bash
# RX 9070 XT (PCI 1002:7550) stats for waybar. Card index can swap with the iGPU.

set -euo pipefail

pci_id="1002:7550"
card=""

for d in /sys/class/drm/card[0-9]; do
  id=$(grep -E '^PCI_ID=' "$d/device/uevent" 2>/dev/null | cut -d= -f2 || true)
  if [[ "$id" == "$pci_id" ]]; then
    card=$d
    break
  fi
done

if [[ -z "$card" ]]; then
  printf '%s\n' '{"text":"GPU n/a","tooltip":"Radeon RX 9070 XT not found","class":"disconnected"}'
  exit 0
fi

dev="$card/device"
busy=$(cat "$dev/gpu_busy_percent" 2>/dev/null || echo 0)
used=$(cat "$dev/mem_info_vram_used" 2>/dev/null || echo 0)
total=$(cat "$dev/mem_info_vram_total" 2>/dev/null || echo 1)

hwmon=""
for h in "$dev/hwmon"/hwmon*; do
  if [[ -f "$h/temp1_input" ]]; then
    hwmon=$h
    break
  fi
done

temp_m=0
power_uw=0
if [[ -n "$hwmon" ]]; then
  temp_m=$(cat "$hwmon/temp1_input" 2>/dev/null || echo 0)
  power_uw=$(cat "$hwmon/power1_average" 2>/dev/null || echo 0)
fi

temp=$((temp_m / 1000))
read -r used_g total_g vram_pct power_w < <(awk -v u="$used" -v t="$total" -v p="$power_uw" 'BEGIN {
  if (t < 1) t = 1
  printf "%.1f %.0f %d %.0f\n", u/1024/1024/1024, t/1024/1024/1024, (u * 100) / t, p/1000000
}')

class="normal"
if (( temp >= 85 || busy >= 95 )); then
  class="critical"
elif (( temp >= 75 || busy >= 80 )); then
  class="warning"
fi

text=$(printf "<span foreground='#727169'>gpu</span>:%d%% %d°" "$busy" "$temp")
tooltip=$(printf "Radeon RX 9070 XT\nLoad: %s%%\nTemp: %s°C (edge)\nVRAM: %s / %s GiB (%s%%)\nPower: %s W" \
  "$busy" "$temp" "$used_g" "$total_g" "$vram_pct" "$power_w")

python3 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"tooltip":sys.argv[2],"class":sys.argv[3],"percentage":int(sys.argv[4])}, ensure_ascii=False))' \
  "$text" "$tooltip" "$class" "$busy"
