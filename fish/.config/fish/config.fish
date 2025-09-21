# =============================================================================
#  LOAD SENSITIVE ENVIRONMENT VARIABLES (e.g., API Keys)
# =============================================================================
# This block checks for a 'secrets.fish' file and sources it if it exists.
# This file is intended for API keys and other secrets and should be in .gitignore.
# =============================================================================
if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# --- Aliases & Environment Variables ---
alias cat 'bat --paging=never'
set -gx VISUAL nvim

# --- Tool Initializations ---
zoxide init fish | source

# =============================================================================
#  CUSTOM FUNCTION: wl-copy with a specific terminal notification
# =============================================================================
# This function wraps 'wl-copy' for terminal-specific pipe operations.
# It uses a backwards-compatible method to check for success.
#
# Usage: echo "some text" | copy
# =============================================================================
function copy --wraps wl-copy --description "Pipe content to wl-copy and send a terminal-specific notification"
    # Execute the original wl-copy command
    command wl-copy $argv

    # Check the exit status in a universally compatible way.
    # If the exit code ($status) is 0, the command was successful.
    if test $status -eq 0
        # Send a notification that clearly indicates the source is the terminal.
        notify-send -a "Terminal" -i "utilities-terminal" "复制成功 (来自终端)" "内容已通过管道命令保存"
    end
end

starship init fish | source

fish_add_path $HOME/.local/bin

# 设置 Android SDK 的根目录
set -x ANDROID_SDK_ROOT "/opt/android-sdk"
set -x ANDROID_AVD_HOME "$HOME/.android/avd"
fish_add_path $ANDROID_SDK_ROOT/cmdline-tools/latest/bin
fish_add_path $ANDROID_SDK_ROOT/platform-tools
fish_add_path $ANDROID_SDK_ROOT/emulator
fish_add_path ~/.npm-global/bin
set -gx ANTHROPIC_API_KEY 'sk-IRxC3rkZofNlJPMuJ22CqD3FTQcAagCtX74UTOvGISso0LWm'
set -gx ANTHROPIC_AUTH_TOKEN 'sk-IRxC3rkZofNlJPMuJ22CqD3FTQcAagCtX74UTOvGISso0LWm'
set -gx ANTHROPIC_BASE_URL 'https://code.ppchat.vip'





# =============================================================================
#  基于 MAC 地址的设备快速连接函数 (V2 - 健壮版)
# =============================================================================
# 这个区块依赖于 ~/.local/bin/get-ip-by-mac.sh 脚本
# -----------------------------------------------------------------------------

# 函数 s_pi: 快速 SSH 连接到树莓派
function s_pi --description "通过 MAC 地址发现并 SSH 连接到树莓派"
    # 1. 调用脚本获取 IP，并将结果存入变量
    set --local pi_ip (get-ip-by-mac.sh pi)
    
    # 2. 检查命令是否成功 (如果 $status 不为 0，则说明失败)
    if test $status -ne 0
        echo "错误: 无法发现树莓派 IP. 请检查网络或 get-ip-by-mac.sh 脚本的日志。" >&2
        return 1 # 以失败状态码退出函数
    end
    
    # 3. 如果成功, 执行连接命令
    echo "==> 发现树莓派 IP: $pi_ip, 正在连接..."
    kitten ssh "pi@$pi_ip"
end

# 函数 f_pi: 快速用 sshfs 挂载树莓派
function f_pi --description "通过 MAC 地址发现并挂载树莓派文件系统"
    # 1. 确保挂载点存在
    mkdir -p ~/pi_mnt_point
    
    # 2. 调用脚本获取 IP
    set --local pi_ip (get-ip-by-mac.sh pi)
    
    # 3. 检查命令是否成功
    if test $status -ne 0
        echo "错误: 无法发现树莓派 IP. 挂载失败。" >&2
        return 1
    end
    
    # 4. 执行挂载命令
    echo "==> 发现树莓派 IP: $pi_ip, 正在挂载到 ~/pi_mnt_point/..."
    sshfs "pi@$pi_ip": ~/pi_mnt_point/
    
    # 检查挂载是否成功
    if test $status -eq 0
        echo "✅ 成功! 树莓派已挂载。"
    else
        echo "❌ 错误: sshfs 挂载失败。" >&2
    end
end

# (可选) 您可以为您其他的设备也创建类似的函数
# 例如, 为您的手机创建 SSH 函数:
# function s_phone1
#     kitten ssh "user@$(get-ip-by-mac.sh phone1)"
# end
