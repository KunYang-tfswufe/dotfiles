if test -f ~/.config/fish/secrets.fish
    source ~/.config/fish/secrets.fish
end

if status is-interactive
    # --- Vi 模式设置 ---
    fish_vi_key_bindings

    # 设置光标形状
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore
    set fish_cursor_visual block

    # Vi 模式下的删除行为修正
    bind -M default d delete-char
    bind -M visual d 'commandline -f kill-selection; commandline -f end-selection; commandline -f repaint'

    # FZF 官方按键绑定
    fzf_key_bindings

end

set -gx EDITOR (command -v hx)
set -gx VISUAL (command -v hx)
set -gx LOCALSTACK_HOST 127.0.0.1

fish_add_path $HOME/.local/bin
fish_add_path ~/go/bin

alias cat 'batcat --paging=never --style="plain"'
alias ls 'eza --git'
alias l 'eza --git'
alias ll 'eza -l --git --header'
alias la 'eza -a --git'
alias lla 'eza -la --git --header'
alias lt 'eza --tree'
alias lta 'eza --tree -a'
alias nano hx
alias ii 'date && echo -n "Bat: " && cat /sys/class/power_supply/BAT*/capacity && hostname -I'

function check_mypublic_dir --on-variable PWD
    set target_dir "$HOME/MyPublic"
    if test "$PWD" = "$target_dir"
        set_color yellow
        echo -n "已进入 MyPublic 目录,执行"
        set_color red
        echo -n ">>>>> pull_mypublic.sh <<<<<"
        set_color yellow
        echo "拉取云端更新."
        set_color normal
    end
end

function copy --wraps wl-copy --description "Pipe to wl-copy and notify"
    command wl-copy $argv
    if test $status -eq 0
        notify-send -a Terminal -i utilities-terminal "复制成功 (来自终端)" 内容已通过管道命令保存
    end
end

function get_ip --description "Discovers a device IP using its MAC address"
    if not command -v arp-scan >/dev/null
        echo "错误: 'arp-scan' 命令未找到。请先安装 (e.g., sudo dnf install arp-scan)" >&2
        return 1
    end

    set --local device_alias $argv[1]
    set --local mac_address
    switch $device_alias
        case pi
            set mac_address 'd8:3a:dd:7e:c5:dc'
        case '*'
            echo "错误: 未知的设备别名 '$device_alias'。" >&2
            return 1
    end

    echo -n "==> 正在扫描 '$device_alias' ($mac_address)... " >&2

    set --local ip (sudo arp-scan -l | grep -i "$mac_address" | awk '{print $1}')

    if test -z "$ip"
        echo "未找到。" >&2
        echo "错误: 未能在网络上找到设备 '$device_alias'。" >&2
        return 1
    end

    echo "找到！" >&2
    echo $ip
end

function s_pi --description "SSH to Raspberry Pi"
    if set --local pi_ip (get_ip pi)
        echo "✅ 发现树莓派 IP: $pi_ip, 正在连接..."
        TERM=xterm-256color ssh "pi@$pi_ip"
    else
        echo "❌ 连接失败：无法获取 IP 地址。" >&2
        return 1
    end
end

function s_phone1 --description "SSH to Phone 1 (Static IP)"
    read --prompt-str "确保手机 Termux 的 sshd 已启动。按 Enter 连接..."
    echo ""
    ssh -p 8022 "9.9.9.9"
end

starship init fish | source
