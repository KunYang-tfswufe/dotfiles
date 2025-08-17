#!/bin/bash

# =====================================================================
# 个人大文件同步脚本 (MyShare) - v4 (Final - Proton Trash)
# 移除了 --backup-dir 以解决 Proton Drive API 的兼容性问题。
# 现在依赖 Proton Drive 自带的回收站功能来防止数据丢失。
# =====================================================================

# --- 配置部分 ---
# 1. 你要同步的大文件夹的绝对路径
SOURCE_DIR="$HOME/MyShare"

# 2. Rclone 配置
# 定义 rclone 远程配置的根
RCLONE_REMOTE_ROOT="ProtonDrive:"

# 目标目录直接在云端根目录下
DEST_DIR="${RCLONE_REMOTE_ROOT}MyShare_sync"

# --- 脚本主体 ---

export TZ='Asia/Shanghai'

echo "🔄 >> 开始增量同步目录: ${SOURCE_DIR}..."

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ 错误: 源目录 ${SOURCE_DIR} 不存在！"
  exit 1
fi

# ======================== START OF MODIFIED SECTION ========================
# 执行 rclone sync 命令
# 我们已经移除了 --backup-dir 参数来避免 Proton Drive 的 API 错误。
# 删除的文件现在会进入 Proton Drive 的回收站。
rclone sync "${SOURCE_DIR}" "${DEST_DIR}" \
    --progress \
    --create-empty-src-dirs
# ========================= END OF MODIFIED SECTION =========================

if [ $? -ne 0 ]; then
  echo "❌ 错误: rclone sync 失败！"
  exit 1
fi

echo "✅ --> 同步完成！"
echo "🏁 >> 同步流程结束！"

exit 0
