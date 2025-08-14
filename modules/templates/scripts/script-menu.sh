#!/bin/bash

# 脚本列表
scripts=(
  "休眠选项:hibernate-menu.sh"
  "键盘重映射:caps2super.sh"
  "屏幕亮度:xscreenlight.sh"
  "系统监视器:mate-system-monitor"
  "切换网关地址:change-gateway.sh"
  "mpv观看B站视频:bbd.sh"
  "按住super键2秒:super-key.sh"
  "通过调节透明度变暗:xscreenlight.sh"
)

# 使用 rofi 显示菜单并获取用户的选择
selected=$(printf "%s\n" "${scripts[@]}" | rofi -dmenu -p "Choose a script to run:")

# 检查用户是否选择了某项
if [ -n "$selected" ]; then
  # 从选择中提取脚本名称
  scripttorun=$(echo "$selected" | cut -d':' -f2)

  # 尝试执行脚本
  if "$scripttorun"; then
    # 脚本执行成功
    :
  else
    # 脚本执行失败，发送通知
    notify-send "The selected script could not be executed."
  fi
else
  notify-send "No script selected."
fi
