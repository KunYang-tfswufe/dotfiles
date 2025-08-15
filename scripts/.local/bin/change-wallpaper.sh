#!/bin/bash

# ------------------- 路径配置（已改为英文） -------------------
WALLPAPER_DIR="$HOME/Pictures/TouhouWallpapers"
mkdir -p "$WALLPAPER_DIR" # 确保目录存在
# -----------------------------------------------------------

# 检查网络连接
if ! ping -c 1 -W 3 8.8.8.8 &> /dev/null; then
    RANDOM_LOCAL_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    if [ -n "$RANDOM_LOCAL_WALLPAPER" ]; then
        # 使用 swww 来设置壁纸
        swww img "$RANDOM_LOCAL_WALLPAPER" --transition-type any
    fi
    exit 0
fi

# --- 配置 ---
MAX_FILES=2

# --- 下载 ---
IMAGE_URL=$(curl -s "https://konachan.net/post.json?limit=100&tags=touhou+rating:safe" | jq -r '.[].file_url' | shuf -n 1)
if [ -z "$IMAGE_URL" ]; then exit 1; fi

# --- 关键修正：确保 date 命令被正确解析 ---
# 我们先获取时间戳，再构建路径，这是最稳妥的办法
TIMESTAMP=$(date +%s)
NEW_WALLPAPER_PATH="$WALLPAPER_DIR/touhou-$TIMESTAMP.jpg"

wget -O "$NEW_WALLPAPER_PATH" "$IMAGE_URL"

if [ ! -s "$NEW_WALLPAPER_PATH" ]; then
    rm -f "$NEW_WALLPAPER_PATH"
    exit 1
fi

# --- 设置 ---
swww img "$NEW_WALLPAPER_PATH" --transition-type wipe --transition-angle 30 --transition-step 90

# --- 清理 ---
NUM_FILES=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f | wc -l)
if [ "$NUM_FILES" -gt "$MAX_FILES" ]; then
    files_to_delete=$(($NUM_FILES - $MAX_FILES))
    find "$WALLPAPER_DIR" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | head -n "$files_to_delete" | cut -d' ' -f2- | xargs -r rm
fi

exit 0
