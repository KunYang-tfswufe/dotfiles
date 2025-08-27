#!/bin/bash

# =======================================================================================
#                      终极安全 Google Drive 同步脚本 (上传)
#
# 功能: 将本地的 'th_' 文件夹同步到 Google Drive。
#
# 安全特性:
# 1. 检查本地源目录是否为空，防止意外清空云端。
# 2. 每次执行前需要用户手动输入 "yes" 确认。
# 3. 使用 --backup-dir 功能，任何在云端被删除的文件都会被移入一个带时间戳的
#    备份文件夹 (rclone_backups/)，相当于云端回收站，防止数据永久丢失。
# =======================================================================================

# 如果任何命令执行失败，则立即退出脚本
set -e

# 定义本地文件夹的基础路径 (HOME 目录)
BASE_DIR="$HOME"
# 创建一个基于当前日期和时间的唯一备份目录名
BACKUP_TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

# 定义一个函数来执行安全的同步操作
safe_sync_upload() {
  local local_dir_name="$1" # 本地文件夹名, e.g., th_00000000yangkun
  local remote_name="$2"    # 远端配置名, e.g., g_00000000yangkun
  local local_full_path="$BASE_DIR/$local_dir_name/"
  # 定义远端的备份目录路径
  local backup_path="${remote_name}:rclone_backups/${BACKUP_TIMESTAMP}"

  echo "--- [准备同步] 本地: '$local_dir_name' -> 云端: '$remote_name' ---"

  # 安全检查 #1: 确认本地目录存在且不为空
  if [ ! -d "$local_full_path" ] || [ -z "$(ls -A "$local_full_path")" ]; then
    echo "❌ 致命错误：本地源目录 '$local_full_path' 不存在或是空的。" >&2
    echo "为防止意外删除云端数据，脚本已中止执行。" >&2
    exit 1 # 立即退出脚本，防止后续操作
  fi
  echo "✅ 本地目录检查通过。"

  # 安全检查 #2: 要求用户手动确认
  read -p "此操作将使云端目录与本地保持一致。是否继续？(请输入 'yes' 确认): " user_confirmation
  if [[ "$user_confirmation" != "yes" ]]; then
    echo "操作已取消。"
    # 这里使用 exit 0，因为这是用户主动取消，并非错误
    exit 0
  fi

  echo "用户已确认。开始同步..."
  echo "ℹ️  提示：任何在云端被删除的文件将被移动到: ${backup_path}"

  # 执行带有 --backup-dir 的 rclone 命令
  rclone sync \
    --progress \
    --backup-dir "$backup_path" \
    "$local_full_path" \
    "${remote_name}:${local_dir_name##*/}" # 使用 ##*/ 来获取路径的最后一部分作为云端目录名

  echo "✅ '$local_dir_name' 同步完成。"
  echo ""
}

echo "====== 开始安全同步音乐文件夹到 Google Drive ======"
echo ""

safe_sync_upload "Music/th_00000000yangkun" "g_00000000yangkun"
safe_sync_upload "Music/th_daisukimarisadaze" "g_daisukimarisadaze"
safe_sync_upload "Music/th_kirisamefreeman" "g_kirisamefreeman"

echo "====== 所有文件夹均已成功同步到云端！ ======"
