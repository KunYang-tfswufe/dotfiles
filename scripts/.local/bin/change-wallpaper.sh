#!/bin/bash

# ------------------- 路径配置 -------------------
WALLPAPER_DIR="$HOME/Pictures/TouhouWallpapers"
mkdir -p "$WALLPAPER_DIR" # 确保目录存在
# -----------------------------------------------------------

# 检查网络连接
if ! ping -c 1 -W 3 8.8.8.8 &> /dev/null; then
    # 网络断开时，从本地已下载的壁纸中随机选择一张
    RANDOM_LOCAL_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    if [ -n "$RANDOM_LOCAL_WALLPAPER" ]; then
        swww img "$RANDOM_LOCAL_WALLPAPER" --transition-type any
    fi
    exit 0
fi

# --- 优化后的配置 ---
# 1. 增加本地缓存文件上限，建立一个丰富的本地壁纸库
MAX_FILES=2
# 2. 设置一个随机页面范围，例如从第1页到第50页
#    这会将你的壁纸池从最新的100张扩展到最新的5000张！
RANDOM_PAGE=$(shuf -i 1-50 -n 1)

# --- 下载 ---
# 在 API 请求中加入 page 参数，实现大范围随机获取
IMAGE_URL=$(curl -s "https://konachan.net/post.json?limit=100&page=${RANDOM_PAGE}&tags=touhou+rating:safe" | jq -r '.[].file_url' | shuf -n 1)

# 如果因为某些原因（比如那一页没有内容）导致 URL 为空，则退出脚本
if [ -z "$IMAGE_URL" ]; then 
    exit 1
fi

# 使用时间戳命名文件，避免重名
TIMESTAMP=$(date +%s)
NEW_WALLPAPER_PATH="$WALLPAPER_DIR/touhou-$TIMESTAMP.jpg"

wget -O "$NEW_WALLPAPER_PATH" "$IMAGE_URL"

# 检查下载的文件是否有效（大小不为0）
if [ ! -s "$NEW_WALLPAPER_PATH" ]; then
    rm -f "$NEW_WALLPAPER_PATH"
    exit 1
fi

# --- 设置壁纸 ---
# 使用 swww 设置新下载的壁纸，并指定一个过渡效果
swww img "$NEW_WALLPAPER_PATH" --transition-type wipe --transition-angle 30 --transition-step 90

# --- 清理旧文件 ---
# 当目录中的文件数量超过 MAX_FILES 时，删除最旧的文件
NUM_FILES=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f | wc -l)
if [ "$NUM_FILES" -gt "$MAX_FILES" ]; then
    # 计算需要删除的文件数量
    files_to_delete=$(($NUM_FILES - $MAX_FILES))
    # 找到修改时间最早的文件并删除它们
    find "$WALLPAPER_DIR" -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | head -n "$files_to_delete" | cut -d' ' -f2- | xargs -r rm
fi

exit 0
