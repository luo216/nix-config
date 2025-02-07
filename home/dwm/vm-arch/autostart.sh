#!/bin/sh

DP=Virtual-1

xrandr --output $DP --mode 1920x1080 --pos 0x0

# notifyd
dunst &

# background
nixGL picom &
feh --bg-fill ~/.local/share/background/background.png
conky &

# mount disk
# udiskie -ans &

# applet
# blueman-applet &
# nm-applet &
# pasystray &

# pinyin
fcitx5 &

# polkit password agent
# /usr/lib/xfce-polkit/xfce-polkit &

# keymap
# caps2super.sh &

nixGLIntel wezterm
