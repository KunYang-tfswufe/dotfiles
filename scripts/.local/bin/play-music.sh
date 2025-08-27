#!/bin/bash

# =====================================================================
# Unified Music Player Script
# Terminates any existing mpv instance, starts a new shuffled
# playlist from all specified music directories, and sends a notification.
# =====================================================================

# First, gently terminate any existing mpv process.
# This prevents multiple players from running and allows the hotkey
# to function as a "play new random mix" button.
killall mpv &> /dev/null || true

# Launch mpv with the --shuffle flag, providing all music directories as arguments.
# The '&' at the end is CRUCIAL. It runs the mpv process in the background,
# allowing the script to immediately continue to the next command (notify-send).
mpv --shuffle \
    "$HOME/Music/th_00000000yangkun" \
    "$HOME/Music/th_daisukimarisadaze" \
    "$HOME/Music/th_kirisamefreeman" &

# Immediately after starting music, send a notification with the current date and time.
# The date format is consistent with your other scripts.
current_time=$(date +"%Y-%m-%d %H:%M:%S")
notify-send "🎶 Now Playing" "Started a new shuffled playlist at:\n$current_time"
