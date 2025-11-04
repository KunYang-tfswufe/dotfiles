# =============================================================================
# Makefile for dotfiles (V7.1 - Smart Systemd Handling)
# =============================================================================

PACKAGES       := nvim scripts espanso fish sway zellij systemd

# ✨ 智能地找出需要直接启用的单元
# 1. 找到所有的 .timer 文件
TIMERS := $(notdir $(wildcard systemd/.config/systemd/user/*.timer))

# 2. 找到所有包含 [Install] 节的 "独立" .service 文件
INSTALLABLE_SERVICES := $(shell for f in systemd/.config/systemd/user/*.service; do \
                                 grep -q '\[Install\]' $$f && echo $$(basename $$f); \
                              done)

# 3. 合并成最终需要管理的单元列表
UNITS_TO_MANAGE := $(TIMERS) $(INSTALLABLE_SERVICES)

.PHONY: all install clean upload help

all: install

install:
	@stow --restow --target=$(HOME) $(PACKAGES)
	@find scripts/.local/bin -type f -name "*.sh" -exec chmod +x {} +
	@echo "==> Enabling systemd units..."
	@systemctl --user daemon-reload
	@if [ -z "$(UNITS_TO_MANAGE)" ]; then \
		echo "   -> No manageable units found."; \
	else \
		for unit in $(UNITS_TO_MANAGE); do \
			echo "   -> Enabling $$unit..."; \
			systemctl --user enable --now $$unit; \
		done; \
	fi
	@echo "✅ Install complete."

clean:
	@echo "==> Disabling systemd units (timers first)..."
	@# ✨ 关键修复：先禁用所有 timers
	@if [ -n "$(TIMERS)" ]; then \
		for unit in $(TIMERS); do \
			echo "   -> Disabling timer: $$unit..."; \
			systemctl --user disable --now $$unit || true; \
		done; \
	fi
	@# ✨ 然后再禁用所有可独立安装的 services
	@if [ -n "$(INSTALLABLE_SERVICES)" ]; then \
		for unit in $(INSTALLABLE_SERVICES); do \
			echo "   -> Disabling service: $$unit..."; \
			systemctl --user disable --now $$unit || true; \
		done; \
	fi
	@systemctl --user daemon-reload
	@echo "==> Unlinking all packages..."
	@stow --delete --target=$(HOME) $(PACKAGES)
	@echo "🗑️  Clean complete."

upload:
	@echo "==> Running the combined upload script..."
	@scripts/.local/bin/upload.sh
	@echo "☁️  All upload tasks complete."

help:
	@echo "Usage: make [target]"
	@echo "  install - Link files, set permissions, enable required systemd units."
	@echo "  clean   - Disable systemd units in correct order and unlink all files."
	@echo "  upload  - Run all upload tasks (dotfiles backup + MyPublic sync)."
	@echo "  help    - Show this help message."
