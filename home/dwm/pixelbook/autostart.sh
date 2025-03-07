#!/bin/bash

DP=eDP-1

xrandr --output $DP --mode 1920x1080 --pos 0x0

# X cursor
xsetroot -xcf ~/.icons/elementary/cursors/default 64

# notifyd
dunst &

# background
feh --bg-fill ~/.local/share/wallpaper/001.png

# mount disk
udiskie -ans &

# applet
nm-applet &
pasystray &
blueman-applet &
xdg-launch org.fcitx.Fcitx5.desktop &
kdeconnect-indicator &
flameshot &

# polkit password agent
/usr/lib/xfce-polkit/xfce-polkit &

# keymap
caps2super.sh &

sleep 1

# Open-source KVM software based on Synergy (GUI)
barrier &

# x11 compositor
nixGLIntel picom &
