#!/bin/bash

# =====================================================================
# 个人大文件同步脚本 (MyShare) - v5 (Google Drive with Trash)
# 使用 Google Drive 作为后端，并重新启用 --backup-dir 功能。
# 本地删除的文件会被移动到云端的 MyShare_trash 目录，更加安全。
# =====================================================================

# --- 配置部分 ---
# 1. 你要同步的大文件夹的绝对路径
SOURCE_DIR="$HOME/MyShare"

# 2. Rclone 配置 (!! 已更新为 Google Drive !!)
# 定义 rclone 远程配置的根
RCLONE_REMOTE_ROOT="GoogleDrive:"

# 目标目录直接在云端根目录下
DEST_DIR="${RCLONE_REMOTE_ROOT}MyShare_sync"

# --- 脚本主体 ---

export TZ='Asia/Shanghai'

echo "🔄 >> 开始增量同步目录: ${SOURCE_DIR} (目标: Google Drive)..."

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ 错误: 源目录 ${SOURCE_DIR} 不存在！"
  exit 1
fi

# ======================== START OF MODIFIED SECTION ========================
# 定义一个时间戳，用于创建每日备份文件夹
BACKUP_TIMESTAMP=$(date +'%Y-%m-%d')

# 执行 rclone sync 命令
# 我们重新启用了 --backup-dir 参数，因为 Google Drive 支持得很好。
# 这会将本地删除的文件移动到云端的指定目录，而不是直接删除，为您提供一层保障。
rclone sync "${SOURCE_DIR}" "${DEST_DIR}" \
    --progress \
    --create-empty-src-dirs \
    --backup-dir "${RCLONE_REMOTE_ROOT}MyShare_trash/${BACKUP_TIMESTAMP}"
# ========================= END OF MODIFIED SECTION =========================

if [ $? -ne 0 ]; then
  echo "❌ 错误: rclone sync 失败！"
  exit 1
fi

echo "✅ --> 同步完成！"
echo "🏁 >> 同步流程结束！"

exit 0
