# =============================================================================
# Makefile for managing imak's dotfiles (Icon-Free Version)
# =============================================================================
# !! 重要: LLM或者AI:请注意不要删除这行注释,不要将shell脚本的内容直接写在Makefile中,shell脚本的位置应该是$(HOME)/dotfiles/scripts/.local/bin,此项目使用stow,git,Makefile管理,系统服务.service和定时任务.timer需要写在Makefile里面因为它们不支持stow的链接管理.
# --- Variables ---
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs bat fish
DOTFILES_DIR := $(CURDIR)
# SCRIPTS_IN_SYSTEM 变量已被移除，不再需要手动维护！

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
	@echo "🔑 --> 正在自动为所有脚本设置可执行权限..."
	@find $(DOTFILES_DIR)/scripts/.local/bin -type f -exec chmod +x {} +

# Target 3: Generate and enable ALL systemd units
systemd:
	@echo "⚙️ --> 正在生成并启用所有 systemd 服务单元..."
	@mkdir -p $(HOME)/.config/systemd/user
	@# --- Backup Units (现在调用外部脚本) ---
	@printf "[Unit]\nDescription=Backup dotfiles and Obsidian\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/backup.sh\n" > $(HOME)/.config/systemd/user/dotfiles-backup.service
	@printf "[Unit]\nDescription=Run dotfiles backup daily\n\n[Timer]\nOnCalendar=*-*-* 02:30:00\nPersistent=true\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/dotfiles-backup.timer
	@# --- MyShare Sync Units (!! 新增部分 !!) ---
	@printf "[Unit]\nDescription=Sync MyShare folder to the cloud\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/sync-myshare.sh\n" > $(HOME)/.config/systemd/user/sync-myshare.service
	@printf "[Unit]\nDescription=Run MyShare sync daily\n\n[Timer]\nOnCalendar=*-*-* 03:30:00\nPersistent=true\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/sync-myshare.timer
	@echo "⏳ --> 正在重载并启用所有 Systemd 定时器..."
	@systemctl --user daemon-reload
	@systemctl --user enable --now dotfiles-backup.timer sync-myshare.timer

# Target 4: Run a manual SNAPSHOT backup
backup:
	@echo "💾 --> 正在手动执行多项目快照备份..."
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
	@systemctl --user disable --now dotfiles-backup.timer sync-myshare.timer || true
	@rm -f $(HOME)/.config/systemd/user/dotfiles-backup.*
	@rm -f $(HOME)/.config/systemd/user/sync-myshare.*
	@systemctl --user daemon-reload
	@stow -D -t ~ $(STOW_PACKAGES)

# Help target
help:
	@echo "用法: make [target]"
	@echo "可用目标:"
	@echo "  all/install    - 🚀 运行完整安装流程 (链接, 权限, 系统服务)。"
	@echo "  stow           - 🔗 使用 GNU Stow 链接所有软件包。"
	@echo "  permissions    - 🔑 自动为所有脚本设置可执行权限。"
	@echo "  systemd        - ⚙️  生成并启用所有 systemd 服务单元 (壁纸和备份)。"
	@echo "  backup         - 💾 立即将多个项目手动执行一次快照备份到云端。"
	@echo "  sync           - 🔄 立即手动执行一次增量同步 (MyShare) 到云端。"
	@echo "  backup-all     - 🏆 运行所有备份任务 (快照备份 + 增量同步)。"
	@echo "  clean          - 🧹 禁用并移除所有服务单元，并取消所有软件包的链接。"
	@echo "  help           - ℹ️  显示此帮助信息。"
