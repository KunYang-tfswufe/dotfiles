# =============================================================================
# Makefile for managing imak's dotfiles (V3.4 - Removed Ollama & Espanso)
# =============================================================================

# --- Variables ---
STOW_PACKAGES := nvim scripts espanso fish sway zellij
DOTFILES_DIR := $(CURDIR)
SYSTEMD_UNITS_SRC := $(DOTFILES_DIR)/systemd-templates/.config/systemd/user

# --- Targets ---
.PHONY: all install permissions stow systemd-user systemd backup sync sync-public backup-all clean help

default: all

install: stow permissions systemd-user
	@echo ">> Dotfiles installation complete! All services are up and running."

stow:
	@echo "--> Linking packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

permissions:
	@echo "--> Setting executable permissions for all scripts..."
	@find $(DOTFILES_DIR)/scripts/.local/bin -type f -exec chmod +x {} +

# ALIAS for backward compatibility, now only runs user services
systemd: systemd-user

systemd-user:
	@echo "--> Installing USER systemd service units from templates..."
	@mkdir -p $(HOME)/.config/systemd/user
	@for template in $(SYSTEMD_UNITS_SRC)/*; do \
		if [ -f "$$template" ]; then \
			target_name=$$(basename "$$template"); \
			echo "    - Installing User Unit: $$target_name"; \
			sed "s|__HOME_DIR__|$(HOME)|g" "$$template" > "$(HOME)/.config/systemd/user/$$target_name"; \
		fi \
	done
	@echo "--> Reloading and enabling all USER Systemd units..."
	@systemctl --user daemon-reload
	# REMOVED: espanso.service is no longer managed here
	@systemctl --user enable --now dotfiles-backup.timer sync-mypublic.timer python-http.service

backup:
	@echo "--> Manually running snapshot backup..."
	@$(HOME)/.local/bin/backup.sh

sync: sync-public

sync-public:
	@echo "--> Manually running incremental sync (MyPublic to GDrive_2TB)..."
	@$(HOME)/.local/bin/sync-mypublic.sh

backup-all: backup sync-public
	@echo ">> All backup tasks (snapshot + sync) completed!"

clean:
	@echo "--> Cleaning up systemd units and unstowing packages..."
	@echo "    - Cleaning user units..."
	# REMOVED: espanso.service is no longer managed here
	@systemctl --user disable --now dotfiles-backup.timer sync-mypublic.timer python-http.service || true
	@for template in $(SYSTEMD_UNITS_SRC)/*; do \
		if [ -f "$$template" ]; then \
			target_name=$$(basename "$$template"); \
			rm -f "$(HOME)/.config/systemd/user/$$target_name"; \
		fi \
	done
	@systemctl --user daemon-reload
	@echo "    - Unstowing packages..."
	@stow -D -t ~ $(STOW_PACKAGES)

help:
	@echo "Usage: make [target]"
	@echo "Available targets:"
	@echo "  all/install    - Run the full installation process."
	@echo "  stow           - Link all packages using GNU Stow."
	@echo "  permissions    - Set executable permissions for all scripts."
	@echo "  systemd        - Install and enable all user systemd units."
	@echo "  backup         - Manually run a snapshot backup."
	@echo "  sync           - Manually run an incremental sync for MyPublic."
	@echo "  backup-all     - Run all backup tasks (snapshot + sync)."
	@echo "  clean          - Disable/remove service units and unstow all packages."
	@echo "  help           - Show this help message."
