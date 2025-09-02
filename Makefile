# =============================================================================
# Makefile for managing imak's dotfiles (V3 - System-level services)
# =============================================================================

# --- Variables ---
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs bat fish lazygit dunst
DOTFILES_DIR := $(CURDIR)
SYSTEMD_UNITS_SRC := $(DOTFILES_DIR)/systemd-templates/.config/systemd/user

# NEW: Define source and destination for system-level drop-in configs
SYSTEMD_SYSTEM_SRC := $(DOTFILES_DIR)/systemd-system-drop-ins

# --- Targets ---
.PHONY: all install permissions stow systemd-user systemd-system systemd backup sync backup-all clean help

default: all

# MODIFIED: 'install' now depends on the new systemd-system target.
# Note: This means 'make install' will require sudo password.
install: stow permissions systemd
	@echo ">> Dotfiles installation complete! All services are up and running."

stow:
	@echo "--> Linking packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

permissions:
	@echo "--> Setting executable permissions for all scripts..."
	@find $(DOTFILES_DIR)/scripts/.local/bin -type f -exec chmod +x {} +

# NEW: Combined systemd target for clarity
systemd: systemd-user systemd-system

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
	@systemctl --user enable --now dotfiles-backup.timer sync-myshare.timer python-http.service

# NEW: Target to handle system-level configurations using sudo
systemd-system:
	@echo "--> Installing SYSTEM systemd drop-in configurations (sudo required)..."
	@echo "    - Installing Ollama CORS override..."
	@sudo mkdir -p /etc/systemd/system/ollama.service.d
	@sudo cp "$(SYSTEMD_SYSTEM_SRC)/ollama.service.d/10-cors-override.conf" /etc/systemd/system/ollama.service.d/
	@echo "--> Reloading SYSTEM daemon and restarting ollama.service..."
	@sudo systemctl daemon-reload
	@sudo systemctl restart ollama.service

backup:
	@echo "--> Manually running snapshot backup..."
	@$(HOME)/.local/bin/backup.sh

sync:
	@echo "--> Manually running incremental sync (MyShare)..."
	@$(HOME)/.local/bin/sync-myshare.sh

backup-all: backup sync
	@echo ">> All backup tasks (snapshot + sync) completed!"

clean:
	@echo "--> Cleaning up systemd units and unstowing packages..."
	@echo "    - Cleaning user units..."
	@systemctl --user disable --now dotfiles-backup.timer sync-myshare.timer python-http.service || true
	@for template in $(SYSTEMD_UNITS_SRC)/*; do \
		if [ -f "$$template" ]; then \
			target_name=$$(basename "$$template"); \
			rm -f "$(HOME)/.config/systemd/user/$$target_name"; \
		fi \
	done
	@systemctl --user daemon-reload
	@echo "    - Cleaning system units (sudo required)..."
	@sudo rm -f /etc/systemd/system/ollama.service.d/10-cors-override.conf
	@sudo systemctl daemon-reload
	@sudo systemctl restart ollama.service || true # Restart if it exists
	@echo "    - Unstowing packages..."
	@stow -D -t ~ $(STOW_PACKAGES)

help:
	@echo "Usage: make [target]"
	@echo "Available targets:"
	@echo "  all/install    - Run the full installation process (requires sudo)."
	@echo "  stow           - Link all packages using GNU Stow."
	@echo "  permissions    - Set executable permissions for all scripts."
	@echo "  systemd        - Install and enable all user and system systemd units (requires sudo)."
	@echo "  backup         - Manually run a snapshot backup."
	@echo "  sync           - Manually run an incremental sync (MyShare)."
	@echo "  backup-all     - Run all backup tasks (snapshot + sync)."
	@echo "  clean          - Disable/remove service units and unstow all packages (requires sudo)."
	@echo "  help           - Show this help message."
