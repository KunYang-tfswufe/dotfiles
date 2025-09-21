#!/bin/bash

#==============================================================================
#          FILE:  update_pi_ip (Bash Version 4.1 - Symlink-safe)
#         USAGE:  ./update_pi_ip
#   DESCRIPTION:  自动发现树莓派 IPv4, 更新 Espanso 配置.
#                 【已修复】此版本能正确处理符号链接, 不会破坏 dotfiles 结构.
#==============================================================================

# --- 配置 ---
espanso_symlink_path="$HOME/.config/espanso/match/shells.yml" # 这是我们检查的路径
pi_hostname="raspberrypi.local"
ip_regex='([0-9]{1,3}\.){3}[0-9]{1,3}'

# --- 颜色定义 ---
COLOR_BLUE='\e[1;34m'
COLOR_GREEN='\e[1;32m'
COLOR_YELLOW='\e[1;33m'
COLOR_RED='\e[1;31m'
COLOR_MAGENTA='\e[1;35m'
COLOR_RESET='\e[0m'

# --- 函数与逻辑 ---
check_dependencies() {
    # ... (此函数无需改变) ...
    if ! command -v avahi-resolve-host-name &> /dev/null; then
        printf "${COLOR_RED}错误: 核心依赖 'avahi' 未找到或相关工具缺失.${COLOR_RESET}\n" >&2
        printf "请运行 'sudo pacman -S avahi' 并启动服务 'sudo systemctl enable --now avahi-daemon.service'.\n" >&2
        exit 1
    fi
    if ! command -v awk &> /dev/null; then
        printf "${COLOR_RED}错误: 核心依赖 'gawk' 未找到.${COLOR_RESET}\n" >&2
        printf "请运行 'sudo pacman -S gawk'.\n" >&2
        exit 1
    fi
}

main() {
    printf "${COLOR_BLUE}==> 开始更新树莓派 IP 地址 (Bash 版 v4.1)...\n${COLOR_RESET}"

    # 【修复核心】首先解析符号链接, 获取真实文件路径
    # readlink -f 会解析所有符号链接并返回绝对物理路径
    local espanso_target_file
    espanso_target_file=$(readlink -f "$espanso_symlink_path")
    
    # 检查原始链接或文件是否存在
    if [[ ! -e "$espanso_symlink_path" ]]; then
        printf "${COLOR_RED}错误: 目标文件或链接不存在于: %s\n${COLOR_RESET}" "$espanso_symlink_path" >&2
        exit 1
    fi

    # 1. 发现新 IP (逻辑不变)
    printf "${COLOR_GREEN}==> 正在网络中查找 '%s' 的 IPv4 地址...\n${COLOR_RESET}" "$pi_hostname"
    local new_pi_ip
    new_pi_ip=$(avahi-resolve-host-name -4 "$pi_hostname" | awk '{print $2}')

    if [[ -z "$new_pi_ip" || ! "$new_pi_ip" =~ $ip_regex ]]; then
        printf "${COLOR_YELLOW}警告: 在网络中找不到 '%s' 或解析 IP 失败.\n${COLOR_RESET}" "$pi_hostname" >&2
        exit 1
    fi

    printf "  [+] 成功发现树莓派! 新 IP 地址为: ${COLOR_MAGENTA}%s\n${COLOR_RESET}" "$new_pi_ip"

    # 2. 从真实文件中提取旧 IP 并进行替换
    local old_ip
    old_ip=$(grep "pi@" "$espanso_target_file" | grep -oE "$ip_regex" | head -n 1)
    
    local old_ip_for_sed
    if [[ -z "$old_ip" ]]; then
        printf "${COLOR_YELLOW}警告: 在目标文件中找不到任何旧的树莓派 IP 地址. 将尝试用通用正则替换.\n${COLOR_RESET}" >&2
        old_ip_for_sed="$ip_regex"
    else
        old_ip_for_sed=$(echo "$old_ip" | sed 's/\./\\./g')
    fi

    if [[ "$old_ip" == "$new_pi_ip" ]]; then
        printf "${COLOR_GREEN}==> IP 地址未变化 (%s), 无需更新. 操作结束.\n${COLOR_RESET}" "$new_pi_ip"
        exit 0
    fi
    
    printf "  [*] 旧 IP 地址为: %s. 准备执行替换...\n" "$old_ip"
    # 现在, sed 操作的是真实的物理文件, 符号链接本身不会被触及
    sed -i -E "/pi@/s/$old_ip_for_sed/$new_pi_ip/g" "$espanso_target_file"

    printf "${COLOR_GREEN}==> 配置文件 '%s' 已更新.\n${COLOR_RESET}" "$espanso_target_file"

    # 3. 重启 Espanso (逻辑不变)
    printf "${COLOR_GREEN}==> 正在重启 Espanso 服务...\n${COLOR_RESET}"
    if espanso restart; then
        printf "${COLOR_BLUE}==> 操作成功! \`sPI 和 \`fPI 已指向新的 IP 地址.\n${COLOR_RESET}"
    else
        printf "${COLOR_RED}错误: 'espanso restart' 命令执行失败.\n${COLOR_RESET}" >&2
        exit 1
    fi
}

# --- 执行 ---
check_dependencies
main
