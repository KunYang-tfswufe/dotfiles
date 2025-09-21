#!/bin/bash

#==============================================================================
#          FILE:  update_pi_ip (Bash Version 4.0)
#         USAGE:  ./update_pi_ip
#   DESCRIPTION:  自动发现树莓派的 IPv4 地址, 并更新 Espanso 配置.
#                 这是从 Fish 脚本 v3.1 移植过来的 Bash 版本.
#==============================================================================

# --- 配置 ---
espanso_target_file="$HOME/.config/espanso/match/shells.yml"
pi_hostname="raspberrypi.local"
# 正则表达式用于匹配 IP 地址
ip_regex='([0-9]{1,3}\.){3}[0-9]{1,3}'

# --- 颜色定义 (用于美化输出) ---
COLOR_BLUE='\e[1;34m'
COLOR_GREEN='\e[1;32m'
COLOR_YELLOW='\e[1;33m'
COLOR_RED='\e[1;31m'
COLOR_MAGENTA='\e[1;35m'
COLOR_RESET='\e[0m'

# --- 函数与逻辑 ---

# 检查脚本所需的核心依赖命令是否存在
check_dependencies() {
    if ! command -v avahi-resolve-host-name &> /dev/null; then
        # 使用 printf 以获得更好的可移植性和对转义序列的处理
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

# 主执行函数
main() {
    printf "${COLOR_BLUE}==> 开始更新树莓派 IP 地址 (Bash 版)...\n${COLOR_RESET}"

    # 使用 [[ ... ]] 是 Bash 更现代和健壮的测试方式
    if [[ ! -f "$espanso_target_file" ]]; then
        printf "${COLOR_RED}错误: 目标文件不存在于: %s\n${COLOR_RESET}" "$espanso_target_file" >&2
        exit 1
    fi

    # 1. 使用 avahi-resolve-host-name 和 awk 精准解析 IPv4 地址
    printf "${COLOR_GREEN}==> 正在网络中查找 '%s' 的 IPv4 地址...\n${COLOR_RESET}" "$pi_hostname"
    
    # 使用 $(...) 进行命令替换是 Bash 的标准做法
    new_pi_ip=$(avahi-resolve-host-name -4 "$pi_hostname" | awk '{print $2}')

    # 检查解析是否成功, 以及结果是否符合 IP 地址格式
    if [[ -z "$new_pi_ip" || ! "$new_pi_ip" =~ $ip_regex ]]; then
        printf "${COLOR_YELLOW}警告: 在网络中找不到 '%s' 或解析 IP 失败.\n${COLOR_RESET}" "$pi_hostname" >&2
        printf "请确认树莓派已开机, 连接到同一局域网, 并且其主机名未被修改.\n" >&2
        exit 1
    fi

    printf "  [+] 成功发现树莓派! 新 IP 地址为: ${COLOR_MAGENTA}%s\n${COLOR_RESET}" "$new_pi_ip"

    # 2. 从目标文件中提取旧 IP 地址
    # grep -o 只输出匹配的部分, head -n 1 取第一个
    old_ip=$(grep "pi@" "$espanso_target_file" | grep -oE "$ip_regex" | head -n 1)

    if [[ -z "$old_ip" ]]; then
        printf "${COLOR_YELLOW}警告: 在目标文件中找不到任何旧的树莓派 IP 地址. 脚本将尝试用通用正则进行替换.\n${COLOR_RESET}" >&2
        # Bash 中直接使用变量即可
        old_ip_for_sed="$ip_regex"
    else
        # 为了让 sed 正确匹配, 需要转义 IP 地址中的 '.'
        old_ip_for_sed=$(echo "$old_ip" | sed 's/\./\\./g')
    fi

    if [[ "$old_ip" == "$new_pi_ip" ]]; then
        printf "${COLOR_GREEN}==> IP 地址未变化 (%s), 无需更新. 操作结束.\n${COLOR_RESET}" "$new_pi_ip"
        exit 0
    fi
    
    printf "  [*] 旧 IP 地址为: %s. 准备执行替换...\n" "$old_ip"
    # 使用 g 标记, 确保一行内所有匹配项都被替换
    sed -i -E "/pi@/s/$old_ip_for_sed/$new_pi_ip/g" "$espanso_target_file"

    printf "${COLOR_GREEN}==> 配置文件 '%s' 已更新.\n${COLOR_RESET}" "$espanso_target_file"

    # 3. 重启 Espanso 服务
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
