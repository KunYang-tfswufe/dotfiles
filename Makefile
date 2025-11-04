# =============================================================================
# Makefile for managing imak's dotfiles (V4.0 - Simplified Systemd Management)
# =============================================================================

# --- Variables ---
# MODIFIED: Added 'systemd' to be managed by stow
STOW_PACKAGES := nvim scripts espanso fish sway zellij systemd
DOTFILES_DIR := $(CURDIR)

# --- Targets ---
.PHONY: all install permissions stow systemd backup sync sync-public backup-all clean help

default: all

install: stow permissions systemd
	@echo ">> Dotfiles installation complete! All services are up and running."

stow:
	@echo "--> Linking packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

permissions:
	@echo "--> Setting executable permissions for all scripts..."
	@find $(DOTFILES_DIR)/scripts/.local/bin -type f -exec chmod +x {} +

# MODIFIED: Simplified systemd target. It no longer uses templates.
# Stow handles placing the files, this target just enables them.
systemd:
	@echo "--> Reloading and enabling all USER Systemd units..."
	@systemctl --user daemon-reload
	@systemctl --user enable --now dotfiles-backup.timer sync-mypublic.timer my-python-server.service

backup:
	@echo "--> Manually running snapshot backup..."
	@$(HOME)/.local/bin/backup.sh

sync: sync-public

sync-public:
	@echo "--> Manually running incremental sync (MyPublic to GDrive_2TB)..."
	@$(HOME)/.local/bin/sync-mypublic.sh

backup-all: backup sync-public
	@echo ">> All backup tasks (snapshot + sync) completed!"

# MODIFIED: Clean target is now much simpler.
clean:
	@echo "--> Disabling systemd units and unstowing packages..."
	@echo "    - Disabling user units..."
	@systemctl --user disable --now dotfiles-backup.timer sync-mypublic.timer my-python-server.service || true
	@systemctl --user daemon-reload
	@echo "    - Unstowing packages..."
	@stow -D -t ~ $(STOW_PACKAGES)

help:
	@echo "Usage: make [target]"
	@echo "Available targets:"
	@echo "  all/install    - Run the full installation process."
	@echo "  stow           - Link all packages using GNU Stow."
	@echo "  permissions    - Set executable permissions for all scripts."
	@echo "  systemd        - Enable and start all user systemd services and timers."
	@echo "  backup         - Manually run a snapshot backup."
	@echo "  sync           - Manually run an incremental sync for MyPublic."
	@echo "  backup-all     - Run all backup tasks (snapshot + sync)."
	@echo "  clean          - Disable service units and unstow all packages."
	@echo "  help           - Show this help message."
