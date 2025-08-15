#!/bin/bash

# --- 配置变量 ---
# 定义你的用户名，让脚本更具可移植性
USERNAME=$(whoami)
# 定义dotfiles仓库的绝对路径
DOTFILES_DIR="/home/$USERNAME/dotfiles"
# Systemd 用户配置目录
SYSTEMD_USER_DIR="/home/$USERNAME/.config/systemd/user"

# --- 脚本开始 ---
echo "🚀 Starting dotfiles installation..."

# 确保目标目录存在
mkdir -p "$SYSTEMD_USER_DIR"

# 1. 使用 Stow 链接所有常规的配置文件包
echo "🔗 Stowing packages: hypr, kitty, nvim, scripts, waybar..."
# -t ~ 指定目标是家目录
stow -t ~ -v hypr kitty nvim scripts waybar

# 2. 使用 Here-Document 生成 Systemd service 文件
echo "📄 Generating change-wallpaper.service..."
cat > "$SYSTEMD_USER_DIR/change-wallpaper.service" << EOL
[Unit]
Description=Change Touhou Wallpaper

[Service]
Type=oneshot
# 脚本会自动被链接到 ~/.local/bin，所以可以直接调用
ExecStart=change-wallpaper.sh
EOL

# 3. 使用 Here-Document 生成 Systemd timer 文件
echo "📄 Generating change-wallpaper.timer..."
cat > "$SYSTEMD_USER_DIR/change-wallpaper.timer" << EOL
[Unit]
Description=Run wallpaper changer on a Pomodoro schedule

[Timer]
# 登录5分钟后第一次运行
OnBootSec=5min
# 之后每隔30分钟运行一次
OnUnitActiveSec=30min

[Install]
WantedBy=timers.target
EOL

# 4. 重新加载 Systemd 并激活定时器
echo "🔁 Reloading and enabling Systemd timer..."
systemctl --user daemon-reload
systemctl --user reenable --now change-wallpaper.timer

echo "✅ Dotfiles installation complete! Your automatic wallpaper system is live."
