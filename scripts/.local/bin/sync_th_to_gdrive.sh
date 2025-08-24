#!/bin/bash

# ==============================================================================
#                            Google Drive 同步脚本
#
# 这个脚本使用 rclone 将本地的 'th_' 音乐文件夹同步到对应的 Google Drive 远端。
# 它会逐一同步以下目录：
#  - 本地: ~/th_00000000yangkun/      ->  远端: g_00000000yangkun
#  - 本地: ~/th_daisukimarisadaze/    ->  远端: g_daisukimarisadaze
#  - 本地: ~/th_kirisamefreeman/      ->  远端: g_kirisamefreeman
#
# `rclone sync` 命令会使远端目录与本地目录完全一致。
#  - 本地新增的文件会被上传。
#  - 本地删除的文件也会在远端被删除。
#  - 只传输有变动的文件，非常节省带宽。
# ==============================================================================

# 如果任何命令执行失败，则立即退出脚本
set -e

# 定义本地文件夹的基础路径 (HOME 目录)
BASE_DIR="$HOME"

echo "====== 开始同步音乐文件夹到 Google Drive ======"
echo ""

# --- 同步 th_00000000yangkun ---
echo "[1/3] 正在同步 th_00000000yangkun ..."
# 命令解释:
# --progress: 显示详细的传输进度
# "$BASE_DIR/th_00000000yangkun/": 本地源目录。注意末尾的'/'代表同步目录内的内容。
# "g_00000000yangkun:th_00000000yangkun": 目标。这会在 g_00000000yangkun 远端的根目录下创建一个名为 th_00000000yangkun 的文件夹并同步。
rclone sync --progress "$BASE_DIR/th_00000000yangkun/" "g_00000000yangkun:th_00000000yangkun"
echo "✅ th_00000000yangkun 同步完成。"
echo ""

# --- 同步 th_daisukimarisadaze ---
echo "[2/3] 正在同步 th_daisukimarisadaze ..."
rclone sync --progress "$BASE_DIR/th_daisukimarisadaze/" "g_daisukimarisadaze:th_daisukimarisadaze"
echo "✅ th_daisukimarisadaze 同步完成。"
echo ""

# --- 同步 th_kirisamefreeman ---
echo "[3/3] 正在同步 th_kirisamefreeman ..."
rclone sync --progress "$BASE_DIR/th_kirisamefreeman/" "g_kirisamefreeman:th_kirisamefreeman"
echo "✅ th_kirisamefreeman 同步完成。"
echo ""

echo "====== 所有文件夹均已同步完成！ ======"
