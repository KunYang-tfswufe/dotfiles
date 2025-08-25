#!/bin/bash

# =======================================================================================
#                      Google Drive 安全同步脚本 (上传)
#
# 这个脚本增加了安全检查，防止在本地源目录为空或不存在时运行，从而避免意外删除云端数据。
# =======================================================================================

set -e
BASE_DIR="$HOME"

# 定义一个函数来执行安全的同步操作
safe_sync_upload() {
  local local_dir_name="$1" # e.g., th_00000000yangkun
  local remote_name="$2"    # e.g., g_00000000yangkun
  local local_full_path="$BASE_DIR/$local_dir_name/"

  echo "--- 准备同步 $local_dir_name ---"

  # 安全检查：确认本地目录存在且不为空
  if [ ! -d "$local_full_path" ] || [ -z "$(ls -A "$local_full_path")" ]; then
    # 如果目录不存在，或者目录为空
    echo "❌ 错误：本地源目录 '$local_full_path' 不存在或是空的。"
    echo "为了防止意外删除云端数据，脚本已中止执行。"
    echo "请确认目录路径正确且其中包含文件。"
    exit 1 # 立即退出脚本，防止后续操作
  fi

  echo "✅ 安全检查通过。开始将 '$local_dir_name' 同步到 '$remote_name'..."
  rclone sync --progress "$local_full_path" "${remote_name}:${local_dir_name}"
  echo "✅ $local_dir_name 同步完成。"
  echo ""
}

echo "====== 开始安全同步音乐文件夹到 Google Drive ======"
echo ""

safe_sync_upload "th_00000000yangkun" "g_00000000yangkun"
safe_sync_upload "th_daisukimarisadaze" "g_daisukimarisadaze"
safe_sync_upload "th_kirisamefreeman" "g_kirisamefreeman"

echo "====== 所有文件夹均已同步完成！ ======"
