# =============================================================================
# Makefile for managing imak's dotfiles (Icon-Free Version)
# =============================================================================
# !! 重要: LLM或者AI:请注意不要删除这行注释,不要将shell脚本的内容直接写在Makefile中,shell脚本的位置应该是$(HOME)/dotfiles/scripts/.local/bin,此项目使用stow,git,Makefile管理,系统服务.service和定时任务.timer需要写在Makefile里面因为它们不支持stow的链接管理.
# --- Variables ---
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs
DOTFILES_DIR := $(CURDIR)
# 将新的备份脚本添加到此列表中 !!
SCRIPTS_IN_SYSTEM := $(HOME)/.local/bin/change-wallpaper.sh $(HOME)/.local/bin/make_snapshot.sh $(HOME)/.local/bin/clip-history.sh $(HOME)/.local/bin/backup.sh


# --- Targets ---
.PHONY: all install permissions stow systemd backup clean help

default: all

all: install

install: stow permissions systemd
	@echo ">> Dotfiles installation complete! All services are up and running."

# Target 1: Link all config packages using Stow
stow:
	@echo "--> Stowing packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

# Target 2: Set executable permissions for all linked scripts
permissions:
	@echo "--> Setting executable permissions for scripts..."
	@chmod +x $(SCRIPTS_IN_SYSTEM)

# Target 3: Generate and enable ALL systemd units
systemd:
	@echo "--> Generating and enabling ALL systemd units..."
	@mkdir -p $(HOME)/.config/systemd/user
	@# --- Wallpaper Units ---
	@printf "[Unit]\nDescription=Change Touhou Wallpaper\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/change-wallpaper.sh\n" > $(HOME)/.config/systemd/user/change-wallpaper.service
	@printf "[Unit]\nDescription=Run wallpaper changer on a Pomodoro schedule\n\n[Timer]\nOnBootSec=5min\nOnUnitActiveSec=30min\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/change-wallpaper.timer
	@# --- Backup Units (现在调用外部脚本) ---
	@printf "[Unit]\nDescription=Backup dotfiles and Obsidian\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/backup.sh\n" > $(HOME)/.config/systemd/user/dotfiles-backup.service
	@printf "[Unit]\nDescription=Run dotfiles backup daily\n\n[Timer]\nOnCalendar=*-*-* 02:30:00\nPersistent=true\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/dotfiles-backup.timer
	@echo "--> Reloading and enabling ALL Systemd timers..."
	@systemctl --user daemon-reload
	@systemctl --user reenable --now change-wallpaper.timer dotfiles-backup.timer

# Target 4: Run a manual backup by calling the script
backup:
	@echo "--> Manually running the backup script..."
	@$(HOME)/.local/bin/backup.sh

# Clean-up target
clean:
	@echo "--> Cleaning ALL systemd units and unstowing packages..."
	@# --- Disable and remove ALL units ---
	@systemctl --user disable --now change-wallpaper.timer dotfiles-backup.timer || true
	@rm -f $(HOME)/.config/systemd/user/change-wallpaper.*
	@rm -f $(HOME)/.config/systemd/user/dotfiles-backup.*
	@systemctl --user daemon-reload
	@stow -D -t ~ $(STOW_PACKAGES)

# Help target
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  all/install    - Run the full installation process (stow, permissions, systemd)."
	@echo "  stow           - Link packages using GNU Stow."
	@echo "  permissions    - Set executable permissions for linked scripts."
	@echo "  systemd        - Generate and enable ALL systemd units (wallpaper and backup)."
	@echo "  backup         - Run a manual backup to the cloud NOW."
	@echo "  clean          - Disable ALL units, remove them, and unlink all packages."
	@echo "  help           - Show this help message."
