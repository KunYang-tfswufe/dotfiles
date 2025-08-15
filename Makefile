# =============================================================================
# Makefile for managing imak's dotfiles (Icon-Free Version)
# =============================================================================

# --- Variables ---
USERNAME := $(shell whoami)
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs
# Define scripts by their final path in the system after stowing
SCRIPTS_IN_SYSTEM := $(HOME)/.local/bin/change-wallpaper.sh $(HOME)/.local/bin/make_snapshot.sh $(HOME)/.local/bin/clip-history.sh

# --- Targets ---
.PHONY: all install permissions stow systemd clean help

default: all

all: install

install: stow permissions systemd
	@echo ">> Dotfiles installation complete! Your system is ready."

# Target 1: Link all config packages using Stow
stow:
	@echo "--> Stowing packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

# Target 2: Set executable permissions for the linked scripts
permissions:
	@echo "--> Setting executable permissions for scripts..."
	@chmod +x $(SCRIPTS_IN_SYSTEM)

# Target 3: Generate and enable the systemd units
systemd:
	@echo "--> Generating and enabling systemd units..."
	@mkdir -p $(HOME)/.config/systemd/user
	@printf "[Unit]\nDescription=Change Touhou Wallpaper\n\n[Service]\nType=oneshot\nExecStart=change-wallpaper.sh\n" > $(HOME)/.config/systemd/user/change-wallpaper.service
	@printf "[Unit]\nDescription=Run wallpaper changer on a Pomodoro schedule\n\n[Timer]\nOnBootSec=5min\nOnUnitActiveSec=30min\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/change-wallpaper.timer
	@echo "--> Reloading and enabling Systemd timer..."
	@systemctl --user daemon-reload
	@systemctl --user reenable --now change-wallpaper.timer

# Clean-up target
clean:
	@echo "--> Cleaning systemd units and unstowing packages..."
	@systemctl --user disable --now change-wallpaper.timer || true
	@rm -f $(HOME)/.config/systemd/user/change-wallpaper.*
	@systemctl --user daemon-reload
	@stow -D -t ~ $(STOW_PACKAGES)

# Help target
help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  all/install    - Run the full installation process."
	@echo "  stow           - Link packages using GNU Stow."
	@echo "  permissions    - Set executable permissions for linked scripts."
	@echo "  systemd        - Generate and enable systemd units."
	@echo "  clean          - Disable units and unlink all packages."
	@echo "  help           - Show this help message."
