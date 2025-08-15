# =============================================================================
# Makefile for managing imak's dotfiles
# =============================================================================

# --- Variables ---
USERNAME := $(shell whoami)
STOW_PACKAGES := hypr kitty nvim scripts waybar espanso configs
# --- 修正之处：将 .fish 改为 .sh ---
SCRIPTS_TO_EXEC := scripts/.local/bin/change-wallpaper.sh scripts/.local/bin/make_snapshot.sh

# --- Targets ---
.PHONY: all install permissions stow systemd clean help

default: all

all: install

install: permissions stow systemd
	@echo "✅ Dotfiles installation complete! Your system is ready."

permissions:
	@echo "🔧 Setting executable permissions for scripts..."
	@chmod +x $(SCRIPTS_TO_EXEC)

stow:
	@echo "🔗 Stowing packages: $(STOW_PACKAGES)..."
	@stow -t ~ -v $(STOW_PACKAGES)

# This target uses printf to generate systemd units, which is the most reliable method.
systemd:
	@echo "📄 Generating and enabling systemd units..."
	@mkdir -p $(HOME)/.config/systemd/user
	@printf "[Unit]\nDescription=Change Touhou Wallpaper\n\n[Service]\nType=oneshot\nExecStart=change-wallpaper.sh\n" > $(HOME)/.config/systemd/user/change-wallpaper.service
	@printf "[Unit]\nDescription=Run wallpaper changer on a Pomodoro schedule\n\n[Timer]\nOnBootSec=5min\nOnUnitActiveSec=30min\n\n[Install]\nWantedBy=timers.target\n" > $(HOME)/.config/systemd/user/change-wallpaper.timer
	@echo "🔁 Reloading and enabling Systemd timer..."
	@systemctl --user daemon-reload
	@systemctl --user reenable --now change-wallpaper.timer

clean:
	@echo "🧹 Cleaning systemd units..."
	@systemctl --user disable --now change-wallpaper.timer || true
	@rm -f $(HOME)/.config/systemd/user/change-wallpaper.*
	@systemctl --user daemon-reload

help:
	@echo "Usage: make [target]"
	@echo "Targets:"
	@echo "  all/install    - Run the full installation process."
	@echo "  permissions    - Only set executable permissions."
	@echo "  stow           - Only link packages using GNU Stow."
	@echo "  systemd        - Only generate and enable systemd units."
	@echo "  clean          - Disable and remove the systemd units."
	@echo "  help           - Show this help message."
