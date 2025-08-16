#!/bin/bash

# =====================================================================
# 个人备份脚本 (Dotfiles & Obsidian) - v2 (Clean Extraction)
# 这个脚本负责执行实际的备份逻辑，并确保解压时目录结构整洁。
# =====================================================================

# --- 配置部分 ---
# 1. Dotfiles 仓库的绝对路径
DOTFILES_DIR="$HOME/dotfiles"

# 2. Obsidian 知识库的绝对路径
OBSIDIAN_DIR="$HOME/SecondBrain"

# 3. Rclone 配置
RCLONE_REMOTE="ProtonDrive:Backups/ArchPC"
DAYS_TO_KEEP=7

# --- 脚本主体 ---

export TZ='Asia/Shanghai'

echo ">> Starting backup process..."

# 检查源目录是否存在
if [ ! -d "$DOTFILES_DIR" ] || [ ! -d "$OBSIDIAN_DIR" ]; then
  echo "错误: Dotfiles 或 Obsidian 目录不存在！请检查脚本中的路径配置。"
  exit 1
fi

# 准备临时文件名和路径
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_FILENAME="backup-${TIMESTAMP}.tar.gz"
LOCAL_ARCHIVE_PATH="/tmp/${BACKUP_FILENAME}"

echo "--> Creating archive: ${BACKUP_FILENAME}"
# ======================== START OF MODIFIED SECTION ========================
# 新的打包方式：
# 1. 我们站在 $HOME 目录 (-C "$HOME")
# 2. 然后告诉 tar 把 dotfiles 和 SecondBrain 这两个文件夹整个打包进去。
tar -I 'gzip --best' -cf "${LOCAL_ARCHIVE_PATH}" \
    --exclude='dotfiles/project_snapshot.txt' \
    --exclude-vcs \
    -C "$HOME" \
    "$(basename "$DOTFILES_DIR")" \
    "$(basename "$OBSIDIAN_DIR")"
# ========================= END OF MODIFIED SECTION =========================

if [ $? -ne 0 ]; then
  echo "错误: 创建压缩包失败！"
  exit 1
fi

echo "--> Uploading archive to ${RCLONE_REMOTE}..."
rclone copyto "${LOCAL_ARCHIVE_PATH}" "${RCLONE_REMOTE}/${BACKUP_FILENAME}" --progress

if [ $? -ne 0 ]; then
  echo "错误: rclone 上传失败！"
  # 保留临时文件以供调试
  exit 1
fi

rm "${LOCAL_ARCHIVE_PATH}"
echo "--> Cleaning up old backups older than ${DAYS_TO_KEEP} days..."
rclone delete "${RCLONE_REMOTE}" --min-age "${DAYS_TO_KEEP}d"
echo ">> Backup complete!"

exit 0
