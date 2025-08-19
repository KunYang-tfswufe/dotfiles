#!/bin/bash

# --- Configuration ---
# A reasonable limit for history entries. 500 is a good balance.
MAX_ENTRIES=500
# Based on the new format (1 separator line + N content lines + 1 blank line),
# we make a safe line count estimate for cleanup.
MAX_LINES_APPROX=$((MAX_ENTRIES * 5))
# Location of the history file
HISTORY_FILE="$HOME/.local/share/clipboard_history"
# Using a temp file to store the last item is the most reliable way to prevent duplicates.
LAST_ITEM_FILE="/tmp/clipboard_last_item"

# --- Export Variables ---
# Export variables so they are visible in the sub-shell created by wl-paste.
export HISTORY_FILE
export MAX_LINES_APPROX
export LAST_ITEM_FILE

# --- Core Processing Function ---
# This function is called every time the clipboard is updated.
process_item() {
    # Get the latest content from the clipboard via wl-paste.
    local item
    item=$(wl-paste --type text --no-newline)

    # Read the previous content for comparison.
    local last_item=""
    if [[ -f "$LAST_ITEM_FILE" ]]; then
        last_item=$(cat "$LAST_ITEM_FILE")
    fi

    # Smart filtering: exit immediately if content is empty or identical to the last one.
    if [[ -z "$item" ]] || [[ "$item" == "$last_item" ]]; then
        return
    fi

    # --- Formatting ---
    # Create a timestamp separator in "--- [YYYY-MM-DD HH:MM:SS] ---" format.
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local separator="--- [${timestamp}] ---"

    # Use printf to precisely construct the block to be written,
    # including the separator, content, and a trailing newline.
    local new_block
    new_block=$(printf "%s\n%s\n" "${separator}" "${item}")

    # Store history: prepend the new block to the file.
    if [[ -f "$HISTORY_FILE" ]]; then
        # Using printf avoids potential escaping issues with echo.
        printf "%s\n" "$new_block" | cat - "$HISTORY_FILE" > /tmp/clipboard_history_temp && mv /tmp/clipboard_history_temp "$HISTORY_FILE"
    else
        # If the file does not exist, create it directly.
        printf "%s\n" "$new_block" > "$HISTORY_FILE"
    fi

    # Update the "last item" record file for the next comparison.
    echo -n "$item" > "$LAST_ITEM_FILE"

    # =======================================================
    #  SEND GLOBAL NOTIFICATION ON ANY SUCCESSFUL COPY
    # =======================================================
    # This command executes for ANY new clipboard entry,
    # regardless of its origin (browser, terminal, etc.).
    notify-send -a "Clipboard" -i "edit-copy" "内容已复制" "新的内容已保存到剪贴板"
    # =======================================================

    # Clean up history: use the approximate total line count to remove the oldest records from the end of the file.
    sed -i -e "$((${MAX_LINES_APPROX}+1)),\$d" "$HISTORY_FILE"
}

# --- Script Main Body ---
# Ensure the directory for the history file exists.
mkdir -p "$(dirname "$HISTORY_FILE")"

# Export the function so it can be called by the child process (wl-paste).
export -f process_item

# Start wl-paste in watch mode, calling our processing function on each clipboard change.
wl-paste --type text --watch bash -c process_item
