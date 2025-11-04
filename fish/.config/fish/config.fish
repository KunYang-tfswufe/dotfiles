# =============================================================================
#  LOAD SENSITIVE ENVIRONMENT VARIABLES
# =============================================================================
if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# =============================================================================
#  ALIASES & ENVIRONMENT
# =============================================================================
set -gx EDITOR (command -v nvim)
set -gx VISUAL (command -v nvim)

fish_add_path $HOME/.local/bin

alias cat 'bat --paging=never --style="plain"'

# --- EZA (ls replacement) Aliases ---
alias ls 'eza --icons --git'
alias l  'eza --icons --git'
alias ll 'eza -l --icons --git --header'
alias la 'eza -a --icons --git'
alias lla 'eza -la --icons --git --header'
alias lt 'eza --tree'
alias lta 'eza --tree -a'

# =============================================================================
#  UTILITY FUNCTIONS
# =============================================================================

# --- wl-copy wrapper with notification ---
function copy --wraps wl-copy --description "Pipe to wl-copy and notify"
    command wl-copy $argv
    if test $status -eq 0
        notify-send -a "Terminal" -i "utilities-terminal" "复制成功 (来自终端)" "内容已通过管道命令保存"
    end
end

# =============================================================================
#  【核心重构】设备发现与连接
# =============================================================================
# 原 get-ip-by-mac.sh 脚本已被整合为下面的 get_ip 函数。
# 所有的设备连接函数现在都依赖于这个内部函数。

# --- 主函数：通过 MAC 地址发现设备 IP ---
# 这个函数是所有动态 IP 连接的基础。
function get_ip --description "Discovers a device IP using its MAC address"
    # 1. 检查依赖项
    if not command -v arp-scan >/dev/null
        echo "错误: 'arp-scan' 命令未找到。请先安装 (e.g., sudo dnf install arp-scan)" >&2
        return 1
    end

    # 2. 定义设备-MAC地址映射
    #    【请务必修改为您自己的 MAC 地址！】
    set --local device_alias $argv[1]
    set --local mac_address
    switch $device_alias
        case 'pi'
            # 示例 MAC 地址，替换为您树莓派的真实地址
            set mac_address 'd8:3a:dd:7e:c5:dc'
        # case 'another_device' # 您可以在这里添加更多设备
        #     set mac_address '...'
        case '*'
            echo "错误: 未知的设备别名 '$device_alias'。请在 get_ip 函数中添加它。" >&2
            return 1
    end

    # 3. 扫描网络并提取 IP
    #    注意：arp-scan 通常需要 root 权限。您可能需要配置无密码 sudo。
    #    (e.g., sudo visudo -> your_user ALL=(ALL) NOPASSWD: /usr/sbin/arp-scan)
    echo "==> 正在使用 MAC [$mac_address] 扫描 '$device_alias'..."
    set --local ip (sudo arp-scan -l | string match -ir $mac_address | awk '{print $1}')

    # 4. 检查结果并返回
    if test -z "$ip"
        echo "错误: 未能在网络上找到设备 '$device_alias'。" >&2
        return 1
    end

    echo $ip # 成功时，将 IP 输出到 stdout
end


# --- 【简化】连接树莓派的系列函数 ---
# 这些函数现在都调用内部的 get_ip 函数，代码更简洁统一。

function s_pi --description "SSH to Raspberry Pi"
    if set --local pi_ip (get_ip pi)
        echo "==> 发现树莓派 IP: $pi_ip, 正在连接..."
        TERM=xterm-256color ssh "pi@$pi_ip"
    else
        return 1 # get_ip 已经打印了错误信息
    end
end

function f_pi --description "Mount Raspberry Pi via sshfs"
    mkdir -p ~/mnt_points/pi_mnt_point
    if set --local pi_ip (get_ip pi)
        echo "==> 发现树莓派 IP: $pi_ip, 正在挂载..."
        sshfs "pi@$pi_ip": ~/mnt_points/pi_mnt_point/
        if test $status -eq 0; echo "✅ 成功! 树莓派已挂载。"; else; echo "❌ 错误: sshfs 挂载失败。" >&2; end
    else
        return 1
    end
end

function vnc_pi --description "VNC to Raspberry Pi"
    echo "提示: 请确保树莓派已启用 VNC 服务，并且您已安装 vncviewer (tigervnc)。"
    read --prompt-str "按 Enter 继续, Ctrl+C 取消..."
    echo ""
    if set --local pi_ip (get_ip pi)
        echo "==> 发现树莓派 IP: $pi_ip, 正在启动 VNC 查看器..."
        vncviewer $pi_ip &
        if test $status -eq 0; echo "✅ VNC 客户端已启动。"; else; echo "❌ 错误: 启动 vncviewer 失败。" >&2; end
    else
        return 1
    end
end


# --- 【保留】连接手机的系列函数（静态IP）---
# 由于手机使用静态IP，其逻辑保持不变，因为它们不依赖于 MAC 地址发现。

function s_phone1 --description "SSH to Phone 1 (Static IP)"
    read --prompt-str "确保手机 Termux 的 sshd 已启动。按 Enter 连接..."
    echo ""
    ssh -p 8022 "9.9.9.9"
end

function f_phone1 --description "Mount Phone 1 via sshfs"
    mkdir -p ~/mnt_points/phone1_mnt
    read --prompt-str "确保手机 Termux 的 sshd 已启动。按 Enter 挂载..."
    echo ""
    sshfs -p 8022 "9.9.9.9:/data/data/com.termux/files/home" ~/mnt_points/phone1_mnt
    if test $status -eq 0; echo "✅ 成功! 手机1已挂载。"; else; echo "❌ 错误: sshfs 挂载失败。" >&2; end
end


# --- 【保留】通用卸载函数 ---

function u_all --description "Unmount all custom mount points"
    echo "正在尝试卸载..."
    fusermount -u ~/mnt_points/pi_mnt_point 2>/dev/null && echo "✓ 树莓派已卸载" || echo "树莓派未挂载或卸载失败"
    fusermount -u ~/mnt_points/phone1_mnt 2>/dev/null && echo "✓ 手机1已卸载" || echo "手机1未挂载或卸载失败"
end
