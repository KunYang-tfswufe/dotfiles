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

# =============================================================================
#  为手机添加的 SSH 连接函数 (V4 - 终极版，包含 MAC 地址设置提醒)
# =============================================================================

# 函数 s_phone1: 通过静态 IP 连接到手机1 (Termux)
function s_phone1 --description "通过静态 IP (9.9.9.9) 连接到手机1"
    set_color yellow
    echo "提醒: 确保手机1已启动 Termux SSH 服务 (sshd)。"
    set_color normal
    read --prompt-str "确认后按 Enter 连接 (Ctrl+C 取消)..."
    
    # 由于手机1已设置静态IP, 直接连接
    echo "" # 添加空行，格式更美观
    echo "==> 直接连接到静态IP: 9.9.9.9, 端口: 8022..."
    kitten ssh -p 8022 "9.9.9.9"
end

# 函数 s_phone2: 快速 SSH 连接到手机2 (Termux)
function s_phone2 --description "提醒后通过 MAC 地址发现并 SSH 连接到手机2 (Termux)"
    set_color yellow
    echo "----------------------- [首次设置检查清单] -----------------------"
    echo "请在安卓手机上, 确保对当前Wi-Fi热点网络已完成以下操作:"
    echo "  1. 【关键】关闭MAC地址随机化: Wi-Fi设置 -> 高级 -> MAC地址类型 -> 使用设备MAC。"
    echo "     (注意: 这可能会改变手机的MAC地址，需要您更新 get-ip-by-mac.sh 脚本!)"
    echo "  2. 【启动】在 Termux 中运行 'sshd' 命令来启动 SSH 服务。"
    echo "  3. 【密码】(如果首次使用) 运行 'passwd' 命令来设置连接密码。"
    echo "-----------------------------------------------------------------"
    set_color normal

    read --prompt-str "确认完成后, 请按 Enter键 继续连接 (按 Ctrl+C 取消)..."
    echo ""
    echo "好的, 正在网络中扫描手机2..."

    set --local phone2_ip (get-ip-by-mac.sh phone2)
    if test $status -ne 0
        echo "错误: 无法发现手机2的 IP 地址。" >&2
        return 1
    end

    echo "==> 发现手机2 IP: $phone2_ip, 正在连接 (Termux)..."
    kitten ssh -p 8022 "$phone2_ip"
end


# =============================================================================
#  为手机添加的 SSHFS 挂载函数 (基于 V4 连接函数)
# =============================================================================

# 函数 f_phone1: 通过静态 IP 挂载手机1的文件系统
function f_phone1 --description "通过静态 IP (9.9.9.9) 挂载手机1 (Termux)"
    # 1. 确保挂载点存在
    mkdir -p ~/phone1_mnt

    set_color yellow
    echo "提醒: 确保手机1已启动 Termux SSH 服务 (sshd)。"
    set_color normal
    read --prompt-str "确认后按 Enter 挂载 (Ctrl+C 取消)..."
    echo ""

    # 2. 执行挂载命令, 注意端口号和远程路径
    echo "==> 连接到静态IP: 9.9.9.9, 端口: 8022, 正在挂载到 ~/phone1_mnt/..."
    # Termux 的主目录完整路径为 /data/data/com.termux/files/home
    sshfs -p 8022 "9.9.9.9:/data/data/com.termux/files/home" ~/phone1_mnt

    # 3. 检查挂载是否成功
    if test $status -eq 0
        echo "✅ 成功! 手机1已挂载。"
    else
        echo "❌ 错误: sshfs 挂载失败。请检查连接或sshd服务。" >&2
    end
end

# 函数 f_phone2: 通过 MAC 地址发现并挂载手机2的文件系统
function f_phone2 --description "通过 MAC 地址发现并挂载手机2 (Termux)"
    # 1. 确保挂载点存在
    mkdir -p ~/phone2_mnt
    
    # 2. 调用 s_phone2 函数中的同款提示，保持用户体验一致
    set_color yellow
    echo "----------------------- [挂载前检查清单] -----------------------"
    echo "请在安卓手机上, 确保对当前Wi-Fi热点网络已完成以下操作:"
    echo "  1. 【关键】关闭MAC地址随机化 -> 使用设备MAC。"
    echo "  2. 【启动】在 Termux 中运行 'sshd' 命令来启动 SSH 服务。"
    echo "----------------------------------------------------------------"
    set_color normal
    read --prompt-str "确认完成后, 请按 Enter键 继续挂载 (按 Ctrl+C 取消)..."
    echo ""

    # 3. 调用脚本获取 IP
    echo "正在网络中扫描手机2..."
    set --local phone2_ip (get-ip-by-mac.sh phone2)

    # 4. 检查命令是否成功
    if test $status -ne 0
        echo "错误: 无法发现手机2的 IP 地址。挂载失败。" >&2
        return 1
    end

    # 5. 执行挂载命令, 注意端口号和远程路径
    echo "==> 发现手机2 IP: $phone2_ip, 正在挂载到 ~/phone2_mnt/..."
    sshfs -p 8022 "$phone2_ip:/data/data/com.termux/files/home" ~/phone2_mnt

    # 6. 检查挂载是否成功
    if test $status -eq 0
        echo "✅ 成功! 手机2已挂载。"
    else
        echo "❌ 错误: sshfs 挂载失败。" >&2
    end
end


# 函数 u_all: 卸载所有已挂载的设备
function u_all --description "卸载所有自定义挂载点 (pi, phone1, phone2)"
    echo "正在尝试卸载挂载点..."
    fusermount -u ~/pi_mnt_point 2>/dev/null && echo "✓ 树莓派已卸载" || echo "树莓派未挂载或卸载失败"
    fusermount -u ~/phone1_mnt 2>/dev/null && echo "✓ 手机1已卸载" || echo "手机1未挂载或卸载失败"
    fusermount -u ~/phone2_mnt 2>/dev/null && echo "✓ 手机2已卸载" || echo "手机2未挂载或卸载失败"
end



# =============================================================================
#  为手机添加的 SCRCPY 无线投屏函数 (基于 V4 连接函数风格)
# =============================================================================

# 函数 scpy_usb: [设置] 通过USB为手机开启无线ADB模式
# 这是每次手机重启后，需要运行一次的“初始化”命令。
function scpy_usb --description "通过USB为手机开启无线ADB模式 (TCP 5555)"
    set_color bryellow
    echo "🔌 请确保手机已通过 USB 连接并已授权..."
    set_color normal
    read --prompt-str "确认后按 Enter 继续 (Ctrl+C 取消)..."
    echo ""

    adb tcpip 5555
    if test $status -eq 0
        set_color green
        echo "✅ 成功! 无线ADB模式已开启。"
        echo "现在可以拔掉 USB 数据线，然后使用 'scpy_phone1' 命令进行连接。"
        set_color normal
    else
        set_color red
        echo "❌ 失败! 请检查手机连接和USB调试授权。" >&2
        set_color normal
    end
end


# 函数 scpy_phone1: [连接] 无线连接并启动 scrcpy 到手机1 (V2 - 健壮版)
# 这是你日常最常用的命令。
function scpy_phone1 --description "通过静态 IP (9.9.9.9) 无线启动 scrcpy"
    set --local PHONE_IP "9.9.9.9" # 你的手机静态IP

    set_color yellow
    echo "------------------- [ scrcpy 无线连接检查 ] -------------------"
    echo "1. 确保手机和电脑在同一网络下。"
    echo "2. 确保手机已开启无线ADB模式。"
    echo "   (如果连接失败, 请先连接USB并运行一次 'scpy_usb')"
    echo "----------------------------------------------------------------"
    set_color normal
    read --prompt-str "确认后按 Enter 连接 (Ctrl+C 取消)..."
    echo ""

    echo "==> 正在连接到 $PHONE_IP:5555..."
    adb connect "$PHONE_IP:5555"

    # 检查 adb connect 是否成功
    if test $status -eq 0
        set_color green
        echo "✅ 连接成功! 正在启动 scrcpy..."
        set_color normal
        # 【关键改动】添加 -e 参数，明确告诉 scrcpy 使用网络设备。
        # 这样即使 USB 还插着，也不会报错。
        scrcpy -e -S --window-title="Phone 1 (scrcpy)"
    else
        set_color red
        echo "❌ 连接失败! 请按提示进行检查。" >&2
        set_color normal
        return 1
    end
end

# 函数 d_phone1: [断开] 断开与手机1的 adb 连接
# 可选的辅助函数，用于清理连接
function d_phone1 --description "断开与手机1 (9.9.9.9) 的 adb 连接"
    echo "==> 正在断开与 9.9.9.9:5555 的连接..."
    adb disconnect 9.9.9.9:5555
end
