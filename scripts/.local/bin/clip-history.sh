#!/bin/bash

# --- Configuration ---
MAX_ENTRIES=500
HISTORY_FILE="$HOME/.local/share/clipboard_history"
LAST_ITEM_FILE="/tmp/clipboard_last_item"

# --- Export Variables ---
export HISTORY_FILE
export LAST_ITEM_FILE
export MAX_ENTRIES

# --- Core Processing Function ---
process_item() {
    local item
    item=$(wl-paste --type text --no-newline)

    local last_item=""
    if [[ -f "$LAST_ITEM_FILE" ]]; then
        last_item=$(cat "$LAST_ITEM_FILE")
    fi

    if [[ -z "$item" ]] || [[ "$item" == "$last_item" ]]; then
        return
    fi

    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local separator="--- [${timestamp}] ---"

    # 【优化 1】使用追加模式，性能更高
    # 我们直接将新条目追加到文件末尾。
    printf "%s\n%s\n\n" "${separator}" "${item}" >> "$HISTORY_FILE"

    echo -n "$item" > "$LAST_ITEM_FILE"

    notify-send -a "Clipboard" -i "edit-copy" "内容已复制" "新的内容已保存到剪贴板"

    # 【优化 2】使用更精确的清理逻辑
    # 我们计算文件中分隔符的数量，如果超过了最大限制，就精确删除最旧的条目。
    # `grep -c` 计算匹配行的数量。
    local entry_count
    entry_count=$(grep -c -- '--- \[' "$HISTORY_FILE")

    if [[ $entry_count -gt $MAX_ENTRIES ]]; then
        # 计算需要删除的条目数
        local entries_to_delete=$((entry_count - MAX_ENTRIES))
        # `grep -n` 找到第 N 个分隔符所在的行号
        local delete_until_line
        delete_until_line=$(grep -n -- '--- \[' "$HISTORY_FILE" | head -n "$entries_to_delete" | tail -n 1 | cut -d: -f1)
        
        # `sed` 从第 N+1 个分隔符的前一行开始删除，直到文件末尾
        # 为了精确，我们先找到第 (N+1) 个分隔符的行号
        local start_line_of_next_entry
        start_line_of_next_entry=$(grep -n -- '--- \[' "$HISTORY_FILE" | head -n $((entries_to_delete + 1)) | tail -n 1 | cut -d: -f1)
        
        # 删除从文件开头到第 (N+1) 个条目之前的所有行
        if [[ -n "$start_line_of_next_entry" ]]; then
            sed -i "1,$((start_line_of_next_entry - 1))d" "$HISTORY_FILE"
        fi
    fi
}

# --- Script Main Body ---
mkdir -p "$(dirname "$HISTORY_FILE")"
export -f process_item
wl-paste --type text --watch bash -c process_item
