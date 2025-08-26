#!/bin/bash

# =====================================================================
# Unified Music Player Script
# Terminates any existing mpv instance and starts a new shuffled
# playlist from all specified music directories.
# =====================================================================

# First, gently terminate any existing mpv process.
# This prevents multiple players from running and allows the hotkey
# to function as a "play new random mix" button.
# The `&> /dev/null || true` ensures the script doesn't fail if no mpv is running.
killall mpv &> /dev/null || true

# Launch mpv with the --shuffle flag, providing all music directories as arguments.
# mpv will scan all paths recursively and create a single, unified playlist.
mpv --shuffle \
    "$HOME/th_00000000yangkun" \
    "$HOME/th_daisukimarisadaze" \
    "$HOME/th_kirisamefreeman"
