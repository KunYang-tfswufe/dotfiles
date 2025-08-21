# =============================================================================
# Makefile for managing imak's dotfiles (V2 - Templating)
# =============================================================================

# --- Variables ---
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs bat fish zellij
DOTFILES_DIR := $(CURDIR)
# NEW: Define the source directory for our systemd templates
SYSTEMD_UNITS_SRC := $(DOTFILES_DIR)/systemd-templates/.config/systemd/user

# --- Targets ---
.PHONY: all install permissions stow systemd backup sync backup-all clean help

default: all

all: install

install: stow permissions systemd
	@echo ">> Dotfiles installation complete! All services are up and running."

stow:
	@echo "--> Linking packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

permissions:
	@echo "--> Setting executable permissions for all scripts..."
	@find $(DOTFILES_DIR)/scripts/.local/bin -type f -exec chmod +x {} +

# MODIFIED: This target is now much cleaner
systemd:
	@echo "--> Installing systemd service units from templates..."
	@mkdir -p $(HOME)/.config/systemd/user
	@# Loop through all template files, replace the placeholder, and copy to the destination
	@for template in $(SYSTEMD_UNITS_SRC)/*; do \
		if [ -f "$$template" ]; then \
			target_name=$$(basename "$$template"); \
			echo "    - Installing $$target_name"; \
			sed "s|__HOME_DIR__|$(HOME)|g" "$$template" > "$(HOME)/.config/systemd/user/$$target_name"; \
		fi \
	done
	@echo "--> Reloading and enabling all Systemd timers..."
	@systemctl --user daemon-reload
	@systemctl --user enable --now dotfiles-backup.timer sync-myshare.timer

backup:
	@echo "--> Manually running snapshot backup..."
	@$(HOME)/.local/bin/backup.sh

sync:
	@echo "--> Manually running incremental sync (MyShare)..."
	@$(HOME)/.local/bin/sync-myshare.sh

backup-all: backup sync
	@echo ">> All backup tasks (snapshot + sync) completed!"

# MODIFIED: This target is now smarter
clean:
	@echo "--> Cleaning up systemd units and unstowing packages..."
	@systemctl --user disable --now dotfiles-backup.timer sync-myshare.timer || true
	@# Remove files based on the source templates, which is more robust
	@for template in $(SYSTEMD_UNITS_SRC)/*; do \
		if [ -f "$$template" ]; then \
			target_name=$$(basename "$$template"); \
			echo "    - Removing $$target_name"; \
			rm -f "$(HOME)/.config/systemd/user/$$target_name"; \
		fi \
	done
	@systemctl --user daemon-reload
	@stow -D -t ~ $(STOW_PACKAGES)

help:
	@echo "Usage: make [target]"
	@echo "Available targets:"
	@echo "  all/install    - Run the full installation process."
	@echo "  stow           - Link all packages using GNU Stow."
	@echo "  permissions    - Set executable permissions for all scripts."
	@echo "  systemd        - Install and enable all systemd service units."
	@echo "  backup         - Manually run a snapshot backup."
	@echo "  sync           - Manually run an incremental sync (MyShare)."
	@echo "  backup-all     - Run all backup tasks (snapshot + sync)."
	@echo "  clean          - Disable/remove service units and unstow all packages."
	@echo "  help           - Show this help message."
