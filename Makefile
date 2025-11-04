# =============================================================================
# Makefile for dotfiles (V7.0 - Final & Pure)
# =============================================================================

PACKAGES       := nvim scripts espanso fish sway zellij systemd
SYSTEMD_UNITS  := $(notdir $(wildcard systemd/.config/systemd/user/*.service systemd/.config/systemd/user/*.timer))

.PHONY: all install clean upload help

all: install

install:
	@stow --restow --target=$(HOME) $(PACKAGES)
	@find scripts/.local/bin -type f -name "*.sh" -exec chmod +x {} +
	@systemctl --user daemon-reload && \
		for unit in $(SYSTEMD_UNITS); do systemctl --user enable --now $$unit; done
	@echo "✅ Install complete."

clean:
	@echo "==> Disabling services and removing links..."
	@for unit in $(SYSTEMD_UNITS); do systemctl --user disable --now $$unit || true; done
	@systemctl --user daemon-reload
	@stow --delete --target=$(HOME) $(PACKAGES)
	@echo "🗑️  Clean complete."

upload:
	@echo "==> Running all upload tasks (backup & sync)..."
	@scripts/.local/bin/backup.sh
	@scripts/.local/bin/sync-mypublic.sh
	@echo "☁️  All upload tasks complete."

help:
	@echo "Usage: make [target]"
	@echo "  install - Link files, set permissions, enable systemd units."
	@echo "  clean   - Disable systemd units and unlink all files."
	@echo "  upload  - Run all upload tasks (dotfiles backup + MyPublic sync)."
	@echo "  help    - Show this help message."
