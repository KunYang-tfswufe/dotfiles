#!/bin/bash

# =====================================================================
# 个人备份脚本 - v4 (可扩展数组)
# 通过修改 BACKUP_TARGETS 数组，轻松管理需要备份的目录。
# =====================================================================

# --- 配置部分 ---
# !! 这是唯一需要修改的地方 !!
# 在这里添加或删除您想要备份的目录的绝对路径。
BACKUP_TARGETS=(
    "$HOME/dotfiles"
    "$HOME/SecondBrain"
    "$HOME/FinalProject"
    "$HOME/sing-box-docs"
)

# Rclone 配置
RCLONE_REMOTE="GoogleDrive:Backups/ArchPC"
DAYS_TO_KEEP=7

# --- 脚本主体 (无需修改以下内容) ---

export TZ='Asia/Shanghai'
echo "🚀 >> 开始备份流程 (目标: Google Drive)..."

# 动态检查所有目标目录是否存在
for target in "${BACKUP_TARGETS[@]}"; do
    if [ ! -d "$target" ]; then
        echo "❌ 错误: 目标目录 '$target' 不存在！请检查脚本配置。"
        exit 1
    fi
done

# 准备临时文件名和路径
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_FILENAME="backup-${TIMESTAMP}.tar.gz"
LOCAL_ARCHIVE_PATH="/tmp/${BACKUP_FILENAME}"

echo "📦 --> 正在创建压缩包: ${BACKUP_FILENAME}"

# 动态生成 tar 命令的参数
tar_targets=()
for target in "${BACKUP_TARGETS[@]}"; do
    tar_targets+=("$(basename "$target")")
done

# 执行打包命令
tar -I 'gzip --best' -cf "${LOCAL_ARCHIVE_PATH}" \
    --exclude='dotfiles/project_snapshot.txt' \
    --exclude-vcs \
    -C "$HOME" \
    "${tar_targets[@]}"

if [ $? -ne 0 ]; then
  echo "❌ 错误: 创建压缩包失败！"
  exit 1
fi

echo "☁️ --> 正在上传压缩包至 ${RCLONE_REMOTE}..."
rclone copyto "${LOCAL_ARCHIVE_PATH}" "${RCLONE_REMOTE}/${BACKUP_FILENAME}" --progress

if [ $? -ne 0 ]; then
  echo "❌ 错误: rclone 上传失败！"
  exit 1
fi

rm "${LOCAL_ARCHIVE_PATH}"
echo "🧹 --> 正在清理 ${DAYS_TO_KEEP} 天前的旧备份..."
rclone delete "${RCLONE_REMOTE}" --min-age "${DAYS_TO_KEEP}d"
echo "✅ >> 备份完成！"

exit 0
