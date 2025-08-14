#!/bin/bash

sleep 0.1

# 获取默认的第一个网关
CURRENT_GATEWAY=$(ip route | grep '^default' | head -n 1 | awk '{print $3}')

# 提取网关的最后一部分
GATEWAY_LAST_PART=$(echo $CURRENT_GATEWAY | awk -F '.' '{print $NF}')

# 判断并切换网关
if [ "$GATEWAY_LAST_PART" == "1" ]; then
  # 使用 rofi 获取 sudo 密码
  password=$(rofi -dmenu -password -i -p "即将切换至旁路由")

  # 如果用户没有输入密码或取消了操作，则退出脚本
  if [ -z "$password" ]; then
    notify-send "未输入密码，操作已取消。"
    exit 1
  fi

  NEW_GATEWAY="${CURRENT_GATEWAY%.*}.254"
  echo "$password" | sudo -S ip route del default via $CURRENT_GATEWAY
  echo "$password" | sudo -S ip route add default via $NEW_GATEWAY
  notify-send "默认网关已从 $CURRENT_GATEWAY 切换到 $NEW_GATEWAY。"
elif [ "$GATEWAY_LAST_PART" == "254" ]; then
  # 使用 rofi 获取 sudo 密码
  password=$(rofi -dmenu -password -i -p "即将切换回主路由")

  # 如果用户没有输入密码或取消了操作，则退出脚本
  if [ -z "$password" ]; then
    notify-send "未输入密码，操作已取消。"
    exit 1
  fi

  NEW_GATEWAY="${CURRENT_GATEWAY%.*}.1"
  echo "$password" | sudo -S ip route del default via $CURRENT_GATEWAY
  echo "$password" | sudo -S ip route add default via $NEW_GATEWAY
  notify-send "默认网关已从 $CURRENT_GATEWAY 切换到 $NEW_GATEWAY。"
else
  notify-send "当前默认网关是 $CURRENT_GATEWAY，既不是 1 也不是 254，不做任何操作。"
fi

notify-send "当前默认网关：$(ip route | grep default | head -n 1 | awk '{print $3}')"
