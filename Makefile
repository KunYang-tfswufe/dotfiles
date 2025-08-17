# =============================================================================
# Makefile for managing imak's dotfiles (Icon-Free Version)
# =============================================================================
# !! 重要: LLM或者AI:请注意不要删除这行注释,不要将shell脚本的内容直接写在Makefile中,shell脚本的位置应该是$(HOME)/dotfiles/scripts/.local/bin,此项目使用stow,git,Makefile管理,系统服务.service和定时任务.timer需要写在Makefile里面因为它们不支持stow的链接管理.
# --- Variables ---
# !! MODIFIED: 'bat' has been added to the list of packages to manage.
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs bat fish
DOTFILES_DIR := $(CURDIR)
# 将新的备份脚本添加到此列表中 !!
SCRIPTS_IN_SYSTEM := $(HOME)/.local/bin/change-wallpaper.sh $(HOME)/.local/bin/make_snapshot.sh $(HOME)/.local/bin/clip-history.sh $(HOME)/.local/bin/backup.sh $(HOME)/.local/bin/sync-myshare.sh


# --- Targets ---
.PHONY: all install permissions stow systemd backup sync backup-all clean help

default: all

all: install

install: stow permissions systemd
	@echo "🎉 >> Dotfiles 安装完成！所有服务已启动并运行。"

# Target 1: Link all config packages using Stow
stow:
	@echo "🔗 --> 正在链接软件包: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

# Target 2: Set executable permissions for all linked scripts
permissions:
	@echo "🔑 --> 正在为脚本设置可执行权限..."
	@chmod +x $(SCRIPTS_IN_SYSTEM)

# Target 3: Generate and enable ALL systemd units
systemd:
	@echo "⚙️ --> 正在生成并启用所有 systemd 服务单元..."
	@mkdir -p $(HOME)/.config/systemd/user
	@# --- Wallpaper Units ---
	@printf "[Unit]\nDescription=Change Touhou Wallpaper\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/change-wallpaper.sh\n" > $(HOME)/.config/systemd/user/change-wallpaper.service
	@printf "[Unit]\nDescription=Run wallpaper changer on a Pomodoro schedule\n\n[Timer]\nOnBootSec=5min\nOnUnitActiveSec=30min\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/change-wallpaper.timer
	@# --- Backup Units (现在调用外部脚本) ---
	@printf "[Unit]\nDescription=Backup dotfiles and Obsidian\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/backup.sh\n" > $(HOME)/.config/systemd/user/dotfiles-backup.service
	@printf "[Unit]\nDescription=Run dotfiles backup daily\n\n[Timer]\nOnCalendar=*-*-* 02:30:00\nPersistent=true\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/dotfiles-backup.timer
	@echo "⏳ --> 正在重载并启用所有 Systemd 定时器..."
	@systemctl --user daemon-reload
	@systemctl --user reenable --now change-wallpaper.timer dotfiles-backup.timer

# Target 4: Run a manual SNAPSHOT backup
backup:
	@echo "💾 --> 正在手动执行快照备份 (dotfiles & obsidian)..."
	@$(HOME)/.local/bin/backup.sh

# Target 5: Run a manual INCREMENTAL sync for MyShare
sync:
	@echo "🔄 --> 正在手动执行增量同步 (MyShare)..."
	@$(HOME)/.local/bin/sync-myshare.sh

# Target 6: Run ALL backup tasks (snapshot + sync)
backup-all: backup sync
	@echo "🏆 >> 所有备份任务 (快照 + 同步) 已完成！"

# Clean-up target
clean:
	@echo "🧹 --> 正在清理所有 systemd 服务单元并取消链接软件包..."
	@# --- Disable and remove ALL units ---
	@systemctl --user disable --now change-wallpaper.timer dotfiles-backup.timer || true
	@rm -f $(HOME)/.config/systemd/user/change-wallpaper.*
	@rm -f $(HOME)/.config/systemd/user/dotfiles-backup.*
	@systemctl --user daemon-reload
	@stow -D -t ~ $(STOW_PACKAGES)

# Help target
help:
	@echo "用法: make [target]"
	@echo "可用目标:"
	@echo "  all/install    - 🚀 运行完整安装流程 (链接, 权限, 系统服务)。"
	@echo "  stow           - 🔗 使用 GNU Stow 链接所有软件包。"
	@echo "  permissions    - 🔑 为所有已链接的脚本设置可执行权限。"
	@echo "  systemd        - ⚙️  生成并启用所有 systemd 服务单元 (壁纸和备份)。"
	@echo "  backup         - 💾 立即手动执行一次快照备份 (dotfiles & obsidian) 到云端。"
	@echo "  sync           - 🔄 立即手动执行一次增量同步 (MyShare) 到云端。"
	@echo "  backup-all     - 🏆 运行所有备份任务 (快照备份 + 增量同步)。"
	@echo "  clean          - 🧹 禁用并移除所有服务单元，并取消所有软件包的链接。"
	@echo "  help           - ℹ️  显示此帮助信息。"
