#!/bin/bash

# =====================================================================
# 个人备份脚本 (Dotfiles & Obsidian & Projects) - v3
# 这个脚本负责执行实际的备份逻辑，并确保解压时目录结构整洁。
# =====================================================================

# --- 配置部分 ---
# 1. Dotfiles 仓库的绝对路径
DOTFILES_DIR="$HOME/dotfiles"

# 2. Obsidian 知识库的绝对路径
OBSIDIAN_DIR="$HOME/SecondBrain"

# 3. FinalProject 项目的绝对路径
FINAL_PROJECT_DIR="$HOME/FinalProject" # <-- 新增

# 4. sing-box-docs 文档的绝对路径
SING_BOX_DOCS_DIR="$HOME/sing-box-docs" # <-- 新增

# 5. Rclone 配置
RCLONE_REMOTE="GoogleDrive:Backups/ArchPC"
DAYS_TO_KEEP=7

# --- 脚本主体 ---

export TZ='Asia/Shanghai'

echo "🚀 >> 开始备份流程 (目标: Google Drive)..."

# 检查源目录是否存在
if [ ! -d "$DOTFILES_DIR" ] || [ ! -d "$OBSIDIAN_DIR" ] || [ ! -d "$FINAL_PROJECT_DIR" ] || [ ! -d "$SING_BOX_DOCS_DIR" ]; then # <-- 修改
  echo "❌ 错误: 一个或多个需要备份的目录不存在！请检查脚本中的路径配置。" # <-- 修改
  exit 1
fi

# 准备临时文件名和路径
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_FILENAME="backup-${TIMESTAMP}.tar.gz"
LOCAL_ARCHIVE_PATH="/tmp/${BACKUP_FILENAME}"

echo "📦 --> 正在创建压缩包: ${BACKUP_FILENAME}"
# ======================== START OF MODIFIED SECTION ========================
# 新的打包方式：
# 1. 我们站在 $HOME 目录 (-C "$HOME")
# 2. 然后告诉 tar 把指定的文件夹整个打包进去。
tar -I 'gzip --best' -cf "${LOCAL_ARCHIVE_PATH}" \
    --exclude='dotfiles/project_snapshot.txt' \
    --exclude-vcs \
    -C "$HOME" \
    "$(basename "$DOTFILES_DIR")" \
    "$(basename "$OBSIDIAN_DIR")" \
    "$(basename "$FINAL_PROJECT_DIR")" \
    "$(basename "$SING_BOX_DOCS_DIR")" # <-- 修改
# ========================= END OF MODIFIED SECTION =========================

if [ $? -ne 0 ]; then
  echo "❌ 错误: 创建压缩包失败！"
  exit 1
fi

echo "☁️ --> 正在上传压缩包至 ${RCLONE_REMOTE}..."
rclone copyto "${LOCAL_ARCHIVE_PATH}" "${RCLONE_REMOTE}/${BACKUP_FILENAME}" --progress

if [ $? -ne 0 ]; then
  echo "❌ 错误: rclone 上传失败！"
  # 保留临时文件以供调试
  exit 1
fi

rm "${LOCAL_ARCHIVE_PATH}"
echo "🧹 --> 正在清理 ${DAYS_TO_KEEP} 天前的旧备份..."
rclone delete "${RCLONE_REMOTE}" --min-age "${DAYS_TO_KEEP}d"
echo "✅ >> 备份完成！"

exit 0
