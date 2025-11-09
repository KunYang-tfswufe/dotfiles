#!/bin/bash

# =====================================================================
# Unified Music Player Script (v3 - Updated for Synced Library)
# Terminates any existing mpv instance, starts a new shuffled
# playlist from the rclone-synced music directory.
# =====================================================================

# First, gently terminate any existing mpv process.
# This prevents multiple players from running and allows the hotkey
# to function as a "play new random mix" button.
killall mpv &> /dev/null || true

# Launch mpv with the --shuffle flag, pointing to the rclone-synced music directory.
# The '&' at the end is CRUCIAL. It runs the mpv process in the background.
mpv --shuffle "$HOME/Music" &

# Immediately after starting music, send a notification with the current date and time.
# The date format is consistent with your other scripts.
current_time=$(date +"%Y-%m-%d %H:%M:%S")
notify-send "🎶 Now Playing" "Started a new shuffled playlist at:\n$current_time"
