#!/bin/sh
c=($(xrandr --query | grep ' connected' | awk '{print $1}'))
if ((${#c[@]} > 1)); then
	xrandr --output eDP1 --mode 1680x1050 --pos 0x279 --rotate normal \
		--output DP1 --off \
		--output DP2 --off \
		--output DP3 --primary --mode 1920x1080 --pos 1050x0 --rotate normal \
		--output DP4 --off \
		--output HDMI1 --off \
		--output VIRTUAL1 --off
else
	xrandr --output eDP1 --primary --mode 1920x1200 --pos 0x0 --rotate normal \
		--output DP1 --off \
		--output DP2 --off \
		--output DP3 --off \
		--output DP4 --off \
		--output HDMI1 --off \
		--output VIRTUAL1 --off
fi
notify-send "screen resolution updated!"

