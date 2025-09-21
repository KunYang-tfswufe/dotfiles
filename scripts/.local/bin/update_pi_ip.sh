#!/bin/bash

#==============================================================================
#          FILE:  update_pi_ip (Bash Version 5.1 - Resilient)
#         USAGE:  update_pi_ip.sh
#   DESCRIPTION:  自动化工作流的最终版, 增加了对首次运行的友好提示.
#==============================================================================

# --- 配置 ---
pi_hostname="raspberrypi.local"
ip_storage_file="$HOME/.pi_ip_address"

# --- 颜色定义 (省略，与之前版本相同) ---
COLOR_BLUE='\e[1;34m'; COLOR_GREEN='\e[1;32m'; COLOR_YELLOW='\e[1;33m';
COLOR_RED='\e[1;31m'; COLOR_MAGENTA='\e[1;35m'; COLOR_RESET='\e[0m';

# --- 依赖检查 (省略，与之前版本相同) ---
check_dependencies() { # ...内容不变...
    if ! command -v avahi-resolve-host-name &> /dev/null; then exit 1; fi
    if ! command -v awk &> /dev/null; then exit 1; fi
}

main() {
    printf "${COLOR_BLUE}==> 开始更新树莓派 IP 地址 (健壮版)...\n${COLOR_RESET}"

    # 1. 发现新 IP (逻辑不变)
    printf "${COLOR_GREEN}==> 正在网络中查找 '%s' 的 IPv4 地址...\n${COLOR_RESET}" "$pi_hostname"
    local new_pi_ip
    new_pi_ip=$(avahi-resolve-host-name -4 "$pi_hostname" | awk '{print $2}')
    
    if [[ -z "$new_pi_ip" || ! "$new_pi_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        printf "${COLOR_YELLOW}警告: 在网络中找不到 '%s' 或解析 IP 失败.\n${COLOR_RESET}" "$pi_hostname" >&2
        exit 1
    fi
    printf "  [+] 成功发现树莓派! 新 IP 地址为: ${COLOR_MAGENTA}%s\n${COLOR_RESET}" "$new_pi_ip"

    # 2. 读取旧 IP, 如果文件不存在则 old_ip 为空
    local old_ip=""
    if [[ -f "$ip_storage_file" ]]; then
        old_ip=$(cat "$ip_storage_file")
    fi

    # 3. 比较 IP
    if [[ "$old_ip" == "$new_pi_ip" ]]; then
        printf "${COLOR_GREEN}==> IP 地址未变化 (%s), 无需更新. 操作结束.\n${COLOR_RESET}" "$new_pi_ip"
        exit 0
    fi
    
    # 4. 【优化】根据旧 IP 是否存在，给出不同的提示信息
    if [[ -z "$old_ip" ]]; then
        printf "  [*] IP 存储文件不存在. 准备进行首次设置...\n"
    else
        printf "  [*] 旧 IP 地址为: %s. 准备更新...\n" "$old_ip"
    fi
    
    echo "$new_pi_ip" > "$ip_storage_file"
    printf "${COLOR_GREEN}==> IP 地址文件 '%s' 已创建/更新.\n${COLOR_RESET}" "$ip_storage_file"
    
    # 5. 重启 Espanso (逻辑不变)
    printf "${COLOR_GREEN}==> 正在重启 Espanso 服务...\n${COLOR_RESET}"
    if espanso restart; then
        printf "${COLOR_BLUE}==> 操作成功! Espanso 已加载新 IP 地址.\n${COLOR_RESET}"
    else
        printf "${COLOR_RED}错误: 'espanso restart' 命令执行失败.\n${COLOR_RESET}" >&2
        exit 1
    fi
}

check_dependencies
main
