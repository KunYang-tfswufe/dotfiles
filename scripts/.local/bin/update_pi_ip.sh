#!/bin/bash
# update_pi_ip.sh (v6.0 - MAC Based) - 依赖于 get-ip-by-mac.sh

# --- 配置 ---
PI_ALIAS="pi" # 我们只需要关心树莓派的别名
ip_storage_file="$HOME/.pi_ip_address"

# ... (省略颜色定义等，可以直接复用我们之前版本的内容) ...
COLOR_BLUE='\e[1;34m'; COLOR_GREEN='\e[1;32m'; COLOR_YELLOW='\e[1;33m';
COLOR_RED='\e[1;31m'; COLOR_MAGENTA='\e[1;35m'; COLOR_RESET='\e[0m';

main() {
    printf "${COLOR_BLUE}==> 开始通过 MAC 地址更新树莓派 IP 地址...\n${COLOR_RESET}"

    # 1. 【核心变更】调用通用脚本来获取IP
    local new_pi_ip
    # 我们在这里静默地执行，因为 get-ip-by-mac.sh 已经有自己的输出了
    new_pi_ip=$(get-ip-by-mac.sh "$PI_ALIAS")

    # 检查通用脚本是否成功
    if [ $? -ne 0 ]; then
        printf "${COLOR_RED}错误: 'get-ip-by-mac.sh' 执行失败. 请检查日志.\n${COLOR_RESET}" >&2
        exit 1
    fi
    printf "  [+] ${COLOR_GREEN}成功发现树莓派! 新 IP 地址为: ${COLOR_MAGENTA}%s\n${COLOR_RESET}" "$new_pi_ip"

    # 2. 读取旧 IP
    local old_ip=""
    if [[ -f "$ip_storage_file" ]]; then old_ip=$(cat "$ip_storage_file"); fi

    # 3. 比较
    if [[ "$old_ip" == "$new_pi_ip" ]]; then
        printf "${COLOR_GREEN}==> IP 地址未变化 (%s), 无需更新. 操作结束.\n${COLOR_RESET}" "$new_pi_ip"
        exit 0
    fi
    
    # 4. 更新
    if [[ -z "$old_ip" ]]; then
        printf "  [*] 首次设置. 正在创建 IP 存储文件...\n"
    else
        printf "  [*] 旧 IP 为: %s. 正在更新...\n" "$old_ip"
    fi
    echo "$new_pi_ip" > "$ip_storage_file"
    printf "  [+] ${COLOR_GREEN}IP 地址文件 '%s' 已更新.\n${COLOR_RESET}" "$ip_storage_file"
    
    # 5. 重启 Espanso
    printf "${COLOR_GREEN}==> 正在重启 Espanso 服务...\n${COLOR_RESET}"
    if espanso restart; then
        printf "${COLOR_BLUE}==> 操作成功! Espanso 已加载新 IP 地址.\n${COLOR_RESET}"
    else
        printf "${COLOR_RED}错误: 'espanso restart' 命令执行失败.\n${COLOR_RESET}" >&2
        exit 1
    fi
}

main
