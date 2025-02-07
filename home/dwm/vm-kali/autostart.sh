#!/bin/bash

DP=Virtual-1

xrandr --output $DP --mode 1920x1080 --pos 0x0

# notifyd
dunst &

# background
feh --bg-fill ~/.local/share/wallpaper/001.png

# mount disk
# udiskie -ans &

# applet
nm-applet &
pasystray &

# polkit password agent
# /usr/lib/xfce-polkit/xfce-polkit &

# keymap
caps2super.sh &

sleep 1

# x11 compositor
nixGLIntel picom &
