#!/bin/bash

# --- 配置 ---
# 设置一个合适的日志限制，500条是一个很好的平衡点
MAX_ENTRIES=500
# 基于新格式（1行分隔符 + N行内容 + 1个空行），我们做一个安全的行数估算用于清理
MAX_LINES_APPROX=$((MAX_ENTRIES * 5))
# 历史记录文件的存放位置
HISTORY_FILE="$HOME/.local/share/clipboard_history"
# 使用一个临时文件来存储上一次复制的内容，这是最可靠的防重方法
LAST_ITEM_FILE="/tmp/clipboard_last_item"

# --- 导出变量 ---
# 将变量导出，以便它们在由 wl-paste 创建的子 shell 中可见
export HISTORY_FILE
export MAX_LINES_APPROX
export LAST_ITEM_FILE

# --- 核心处理函数 ---
# 此函数会在每次剪贴板更新时被调用
process_item() {
    # 从 wl-paste 获取当前剪贴板的最新内容
    local item
    item=$(wl-paste --type text --no-newline)

    # 读取上一次的内容用于比较
    local last_item=""
    if [[ -f "$LAST_ITEM_FILE" ]]; then
        last_item=$(cat "$LAST_ITEM_FILE")
    fi

    # 智能过滤：如果内容为空或与上一次完全相同，则立即退出
    if [[ -z "$item" ]] || [[ "$item" == "$last_item" ]]; then
        return
    fi

    # --- 格式化部分 ---
    # 创建 "--- [YYYY-MM-DD HH:MM:SS] ---" 格式的时间戳分隔符
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local separator="--- 📋 [${timestamp}] ---"
    
    # 使用 printf 来精确构建要写入的块，包含分隔符、内容和末尾的空行
    local new_block
    new_block=$(printf "%s\n%s\n" "${separator}" "${item}")

    # 存储历史：将新块添加到文件顶部
    if [[ -f "$HISTORY_FILE" ]]; then
        # 使用 printf 可以避免 echo 带来的潜在转义问题
        printf "%s\n" "$new_block" | cat - "$HISTORY_FILE" > /tmp/clipboard_history_temp && mv /tmp/clipboard_history_temp "$HISTORY_FILE"
    else
        # 如果文件不存在，直接创建它
        printf "%s\n" "$new_block" > "$HISTORY_FILE"
    fi

    # 更新“上一次内容”的记录文件，以备下次比较
    echo -n "$item" > "$LAST_ITEM_FILE"

    # 清理历史：使用近似的总行数来删除文件末尾最旧的记录
    sed -i -e "$((${MAX_LINES_APPROX}+1)),\$d" "$HISTORY_FILE"
}

# --- 脚本主体 ---
# 确保历史文件所在的目录存在
mkdir -p "$(dirname "$HISTORY_FILE")"

# 导出函数，这样它才能被子进程(wl-paste)调用
export -f process_item

# 启动 wl-paste 的监听模式，在每次剪贴板变化时调用我们的处理函数
wl-paste --type text --watch bash -c process_item
