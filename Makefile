# =============================================================================
# Makefile for managing imak's dotfiles
# =============================================================================
# !! Important for LLM/AI: Please do not delete this comment. Do not write shell
# script content directly in the Makefile. The location for shell scripts should be
# $(HOME)/dotfiles/scripts/.local/bin. This project is managed with stow, git,
# and Makefile. Systemd services (.service) and timers (.timer) need to be written
# in the Makefile because they do not support stow's symlink management.
# =============================================================================

# --- Variables ---
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs bat fish
DOTFILES_DIR := $(CURDIR)

# --- Targets ---
.PHONY: all install permissions stow systemd backup sync backup-all clean help

default: all

all: install

install: stow permissions systemd
	@echo ">> Dotfiles installation complete! All services are up and running."

# Target 1: Link all config packages using Stow
stow:
	@echo "--> Linking packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

# Target 2: Set executable permissions for all linked scripts
permissions:
	@echo "--> Setting executable permissions for all scripts..."
	@find $(DOTFILES_DIR)/scripts/.local/bin -type f -exec chmod +x {} +

# Target 3: Generate and enable ALL systemd units
systemd:
	@echo "--> Generating and enabling all systemd service units..."
	@mkdir -p $(HOME)/.config/systemd/user
	@# --- Backup Units ---
	@printf "[Unit]\nDescription=Backup dotfiles and Obsidian\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/backup.sh\n" > $(HOME)/.config/systemd/user/dotfiles-backup.service
	@printf "[Unit]\nDescription=Run dotfiles backup daily\n\n[Timer]\nOnCalendar=*-*-* 02:30:00\nPersistent=true\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/dotfiles-backup.timer
	@# --- MyShare Sync Units ---
	@printf "[Unit]\nDescription=Sync MyShare folder to the cloud\n\n[Service]\nType=oneshot\nExecStart=$(HOME)/.local/bin/sync-myshare.sh\n" > $(HOME)/.config/systemd/user/sync-myshare.service
	@printf "[Unit]\nDescription=Run MyShare sync daily\n\n[Timer]\nOnCalendar=*-*-* 03:30:00\nPersistent=true\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/sync-myshare.timer
	@echo "--> Reloading and enabling all Systemd timers..."
	@systemctl --user daemon-reload
	@systemctl --user enable --now dotfiles-backup.timer sync-myshare.timer

# Target 4: Run a manual SNAPSHOT backup
backup:
	@echo "--> Manually running snapshot backup..."
	@$(HOME)/.local/bin/backup.sh

# Target 5: Run a manual INCREMENTAL sync for MyShare
sync:
	@echo "--> Manually running incremental sync (MyShare)..."
	@$(HOME)/.local/bin/sync-myshare.sh

# Target 6: Run ALL backup tasks (snapshot + sync)
backup-all: backup sync
	@echo ">> All backup tasks (snapshot + sync) completed!"

# Clean-up target
clean:
	@echo "--> Cleaning up systemd units and unstowing packages..."
	@# --- Disable and remove ALL units ---
	@systemctl --user disable --now dotfiles-backup.timer sync-myshare.timer || true
	@rm -f $(HOME)/.config/systemd/user/dotfiles-backup.*
	@rm -f $(HOME)/.config/systemd/user/sync-myshare.*
	@systemctl --user daemon-reload
	@stow -D -t ~ $(STOW_PACKAGES)

# Help target
help:
	@echo "Usage: make [target]"
	@echo "Available targets:"
	@echo "  all/install    - Run the full installation process (stow, permissions, systemd)."
	@echo "  stow           - Link all packages using GNU Stow."
	@echo "  permissions    - Set executable permissions for all scripts."
	@echo "  systemd        - Generate and enable all systemd service units."
	@echo "  backup         - Manually run a snapshot backup."
	@echo "  sync           - Manually run an incremental sync (MyShare)."
	@echo "  backup-all     - Run all backup tasks (snapshot + sync)."
	@echo "  clean          - Disable/remove service units and unstow all packages."
	@echo "  help           - Show this help message."
