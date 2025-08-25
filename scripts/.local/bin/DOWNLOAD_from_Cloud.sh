#!/bin/bash

# =======================================================================================
#                      安全 Google Drive 恢复脚本 (下载)
#
# 功能: 从 Google Drive 将 'th_' 文件夹恢复到本地。
#
# 安全特性:
# 1. 每次执行前会发出明确警告，告知用户此操作会删除本地多余文件。
# 2. 需要用户手动输入 "yes" 确认，防止意外覆盖本地数据。
#
# **请仅在重装系统后或确认本地文件夹可被覆盖时使用此脚本！**
# =======================================================================================

# 如果任何命令执行失败，则立即退出脚本
set -e

# 定义本地文件夹的基础路径 (HOME 目录)
BASE_DIR="$HOME"

# 定义一个函数来执行安全的恢复操作
safe_sync_download() {
  local remote_name="$1"    # 远端配置名, e.g., g_00000000yangkun
  local local_dir_name="$2" # 本地文件夹名, e.g., th_00000000yangkun
  local local_full_path="$BASE_DIR/$local_dir_name/"
  local remote_full_path="${remote_name}:${local_dir_name}"

  echo "--- [准备恢复] 云端: '$remote_name/$local_dir_name' -> 本地: '$local_full_path' ---"

  # 安全检查: 要求用户手动确认
  echo "⚠️  警告：此操作将使本地文件夹 '$local_full_path' 与云端完全同步。"
  echo "这意味着本地文件夹中任何云端没有的文件都将被【永久删除】。"
  read -p "您确定要继续吗？(请输入 'yes' 确认): " user_confirmation
  if [[ "$user_confirmation" != "yes" ]]; then
    echo "操作已取消。"
    exit 0
  fi

  echo "用户已确认。开始从云端恢复..."

  # rclone 会自动创建不存在的本地目录
  rclone sync \
    --progress \
    "$remote_full_path" \
    "$local_full_path"

  echo "✅ '$local_dir_name' 恢复完成。"
  echo ""
}

echo "====== 开始从 Google Drive 恢复音乐文件夹 ======"
echo ""

safe_sync_download "g_00000000yangkun" "th_00000000yangkun"
safe_sync_download "g_daisukimarisadaze" "th_daisukimarisadaze"
safe_sync_download "g_kirisamefreeman" "th_kirisamefreeman"

echo "====== 所有文件夹均已成功从云端恢复！ ======"
