#!/bin/sh
c=($(xrandr --query | grep ' connected' | awk '{print $1}'))
xrandr --output eDP1 --primary --mode 1920x1200 --pos 0x0 --rotate normal
if ((${#c[@]} > 1)); then
	xrandr	--output DP1 --off \
		--output DP2 --off \
		--output DP3 --mode 1920x1080 --pos 0x0 --rotate normal \
		--output DP4 --off \
		--output HDMI1 --off \
		--output VIRTUAL1 --of
fi
notify-send "screen resolution updated!"

