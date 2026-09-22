#!/usr/bin/env bash
# Per-NVMe disk usage + temperature for waybar.
#
#   usage : used/(used+avail) of the drive's primary mounted filesystem
#           ("/" is preferred, otherwise the largest mount on that drive)
#   temp  : the HOTTEST temperature channel the drive reports (composite or any
#           of its physical sensors), read from the kernel hwmon interface
#
# Emits waybar JSON: two stacked lines, one per NVMe drive.
# Requires no privileges.

set -euo pipefail

shopt -s nullglob

lines=()
tips=()
cls="normal"

for dev_path in /sys/class/nvme/nvme*; do
  [[ -d "$dev_path" ]] || continue

  dev=${dev_path##*/}          # nvme0
  short=${dev/nvme/n}          # n0
  model=$(tr -s ' \t' ' ' <"$dev_path/model" 2>/dev/null || true)
  model=${model%% }

  # --- temperatures: every channel the drive reports, millidegrees C ---
  hot_mc=-1
  hot_lbl=""
  rows=()
  for tfile in "$dev_path"/hwmon*/temp*_input; do
    [[ -r "$tfile" ]] || continue
    base=${tfile%_input}
    mc=$(cat "$tfile")
    lbl=$(cat "${base}_label" 2>/dev/null || basename "$base")
    if (( mc > hot_mc )); then
      hot_mc=$mc
      hot_lbl=$lbl
    fi
    rows+=("${lbl}|${mc}")
  done

  # --- primary mountpoint on this drive, prefer "/" ---
  mp=""
  best=0
  while read -r src tgt size; do
    [[ "$src" == /dev/${dev}n* ]] || continue
    if [[ "$tgt" == "/" ]]; then
      mp="/"
      break
    fi
    if (( size > best )); then
      best=$size
      mp=$tgt
    fi
  done < <(findmnt -rno SOURCE,TARGET,SIZE --bytes 2>/dev/null || true)

  # --- usage of that mountpoint ---
  pct=""
  detail="not mounted"
  if [[ -n "$mp" ]]; then
    read -r used avail total < <(df -B1 --output=used,avail,size "$mp" | tail -n1)
    if (( used + avail > 0 )); then
      pct=$(( used * 100 / (used + avail) ))
    fi
    detail=$(printf '%s  %s / %s used (%s%%)' \
      "$mp" \
      "$(numfmt --to=iec "$used")" \
      "$(numfmt --to=iec "$total")" \
      "${pct:-0}")
  fi

  # --- severity for colouring / waybar class ---
  usage_col="#a4b9ef"           # lavender (normal)
  if [[ -n "$pct" ]]; then
    if (( pct >= 90 )); then usage_col="#e82424"; cls="critical"
    elif (( pct >= 80 )); then usage_col="#dca561"
      [[ "$cls" == normal ]] && cls="warning"
    fi
  fi

  temp_col="#7dc4e4"            # sky (normal)
  if (( hot_mc >= 0 )); then
    hot=$(( (hot_mc + 500) / 1000 ))   # round to nearest °C
    temp_txt="${hot}°"
    if (( hot >= 90 )); then temp_col="#e82424"; cls="critical"
    elif (( hot >= 80 )); then temp_col="#dca561"
      [[ "$cls" == normal ]] && cls="warning"
    fi
  else
    temp_txt="--"
  fi

  usage_txt="--"
  [[ -n "$pct" ]] && usage_txt="${pct}%"

  # --- render one line for the bar ---
  lines+=("<span size='smaller' foreground='#727169'>${short}</span> <span size='smaller' foreground='${usage_col}'>${usage_txt}</span> <span size='smaller' foreground='${temp_col}'>${temp_txt}</span>")

  # --- tooltip: usage + every temperature channel, hottest marked ---
  tip_block="$dev  $model
  $detail"
  for row in "${rows[@]}"; do
    lbl=${row%%|*}
    mc=${row##*|}
    deg="$((mc / 1000)).$((mc % 1000 / 100))"
    if [[ "$lbl" == "$hot_lbl" ]]; then
      mark="   <- hottest"
    else
      mark=""
    fi
    tip_block+=$(printf '\n  %-9s %s°C%s' "$lbl" "$deg" "$mark")
  done
  tips+=("$tip_block")
done

if (( ${#lines[@]} == 0 )); then
  text="<span foreground='#727169'>no nvme</span>"
else
  text="<span line_height='0.8'>"
  for i in "${!lines[@]}"; do
    (( i > 0 )) && text+=$'\n'
    text+="${lines[$i]}"
  done
  text+="</span>"
fi

printf -v tip '%s\n' "${tips[@]}"

python3 -c 'import json,sys; print(json.dumps({"text":sys.argv[1],"tooltip":sys.argv[2].rstrip("\n"),"class":sys.argv[3]}, ensure_ascii=False))' \
  "$text" "$tip" "$cls"
