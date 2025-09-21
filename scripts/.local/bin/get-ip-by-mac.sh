#!/bin/bash

#==============================================================================
#          FILE:  get-ip-by-mac.sh (v1.1 - Resilient to Duplicates)
#         USAGE:  get-ip-by-mac.sh <device_alias>
#   DESCRIPTION:  通过 MAC 地址查找 IP。增加了 head -n 1 来处理重复的 ARP 响应。
#==============================================================================

set -eo pipefail 

# --- 设备通讯录 ---
get_mac_by_alias() {
    local MAC_ADDRESS=""
    case "$1" in
        "pi")       MAC_ADDRESS="d8:3a:dd:7e:c5:dc" ;; 
        "phone1")   MAC_ADDRESS="d6:51:bb:10:0e:54" ;; 
        "phone2")   MAC_ADDRESS="74:38:22:99:7e:b1" ;; 
        *)          
            printf "错误: 未知的设备别名 '%s'\\n" "$1" >&2
            printf "可用别名: pi, phone1, phone2\\n" >&2
            exit 1 
            ;;
    esac
    echo "$MAC_ADDRESS"
}

# --- 脚本主逻辑 ---
if [ -z "$1" ]; then
    printf "用法: %s <device_alias>\\n" "$0" >&2
    exit 1
fi

DEVICE_ALIAS="$1"
TARGET_MAC=$(get_mac_by_alias "$DEVICE_ALIAS")

if ! command -v arp-scan &> /dev/null; then
    printf "错误: 核心依赖 'arp-scan' 未找到.\\n" >&2
    exit 1
fi

# 屏蔽 arp-scan 自身的扫描信息，让主脚本控制输出
# 【核心修正】在管道末尾添加 head -n 1 来确保只取唯一的IP地址
DEVICE_IP=$(sudo arp-scan -l 2>/dev/null | grep -i "$TARGET_MAC" | awk '{print $1}' | head -n 1)

if [ -n "$DEVICE_IP" ]; then
    echo "$DEVICE_IP"
else
    # 错误信息现在由主脚本控制
    exit 1
fi
