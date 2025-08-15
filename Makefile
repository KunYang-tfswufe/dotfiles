# =============================================================================
# Makefile for managing imak's dotfiles
# =============================================================================

# --- 变量定义 ---
# 使用 $(shell ...) 来动态获取用户名，更符合Makefile的风格
USERNAME := $(shell whoami)
# 定义所有需要被Stow管理的包
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs
# 定义所有需要被设置为可执行的脚本
# 注意：Makefile中，变量赋值通常用 :=
SCRIPTS_TO_EXEC := scripts/.local/bin/change-wallpaper.sh scripts/.local/bin/make_snapshot.fish install.sh

# --- 任务(Targets)定义 ---

# .PHONY 告诉make这些不是真实的文件名，而是任务名
.PHONY: all install permissions stow systemd clean help

# 默认任务: 当只输入`make`时，会执行`all`任务
default: all

# 'all' 任务是所有安装步骤的集合，也是最常用的命令
all: install

# 'install' 任务按顺序执行所有必要的子任务
install: permissions stow systemd
	@echo "✅ Dotfiles installation complete! Your system is ready."

# 任务1: 设置所有脚本的可执行权限
permissions:
	@echo "🔧 Setting executable permissions for scripts..."
	@chmod +x $(SCRIPTS_TO_EXEC)

# 任务2: 使用Stow链接所有配置文件包
stow:
	@echo "🔗 Stowing packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

# 任务3: 生成并激活Systemd单元文件
systemd:
	@echo "📄 Generating and enabling systemd units..."
	@mkdir -p $(HOME)/.config/systemd/user
	@cat > $(HOME)/.config/systemd/user/change-wallpaper.service << EOL
[Unit]
Description=Change Touhou Wallpaper
[Service]
Type=oneshot
ExecStart=change-wallpaper.sh
EOL
	@cat > $(HOME)/.config/systemd/user/change-wallpaper.timer << EOL
[Unit]
Description=Run wallpaper changer on a Pomodoro schedule
[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
[Install]
WantedBy=timers.target
EOL
	@echo "🔁 Reloading and enabling Systemd timer..."
	@systemctl --user daemon-reload
	@systemctl --user reenable --now change-wallpaper.timer

# 清理任务: 用于卸载systemd单元
clean:
	@echo "🧹 Cleaning systemd units..."
	@systemctl --user disable --now change-wallpaper.timer || true
	@rm -f $(HOME)/.config/systemd/user/change-wallpaper.*
	@systemctl --user daemon-reload

# 帮助任务: 让你知道有哪些命令可用
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  all/install    - Run the full installation process (permissions, stow, systemd)."
	@echo "  permissions    - Only set executable permissions for scripts."
	@echo "  stow           - Only link packages using GNU Stow."
	@echo "  systemd        - Only generate and enable systemd units."
	@echo "  clean          - Disable and remove the systemd units."
	@echo "  help           - Show this help message."
