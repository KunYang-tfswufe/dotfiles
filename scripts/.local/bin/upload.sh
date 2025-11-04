#!/bin/bash

# =====================================================================
#  统一上传脚本 - v2.0
#  - 集合了 dotfiles 备份 和 MyPublic 目录同步功能
#  - 依赖: rclone, tar, gzip
# =====================================================================

# --- 脚本核心设置 ---
# 如果任何命令失败，立即退出脚本
set -e

# --- 统一配置区 (所有配置都在这里修改) ---
# 1. dotfiles 备份配置
BACKUP_TARGETS=(
    "$HOME/dotfiles"
)
BACKUP_REMOTE="GDrive_2TB:Backups/ArchPC"
DAYS_TO_KEEP=7

# 2. MyPublic 同步配置
PUBLIC_SOURCE_DIR="$HOME/MyPublic"
PUBLIC_REMOTE_ROOT="GDrive_2TB:"


# --- 功能函数定义区 ---

# 函数: 备份 dotfiles
function backup_dotfiles() {
    echo "--> [1/2] 正在开始 dotfiles 备份任务 (目标: $BACKUP_REMOTE)..."

    # 动态检查所有目标目录是否存在
    for target in "${BACKUP_TARGETS[@]}"; do
        if [ ! -d "$target" ]; then
            echo "错误: 目标备份目录 '$target' 不存在！请检查配置。" >&2
            return 1 # 返回错误码
        fi
    done

    # 准备临时文件名和路径
    local TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
    local BACKUP_FILENAME="backup-${TIMESTAMP}.tar.gz"
    local LOCAL_ARCHIVE_PATH="/tmp/${BACKUP_FILENAME}"

    echo "    -> 正在创建压缩包: ${LOCAL_ARCHIVE_PATH}"

    # 动态生成 tar 命令的参数
    local tar_targets=()
    for target in "${BACKUP_TARGETS[@]}"; do
        tar_targets+=("$(basename "$target")")
    done

    # 执行打包命令
    tar -I 'gzip --best' -cf "${LOCAL_ARCHIVE_PATH}" \
        --exclude='dotfiles/project_snapshot.txt' \
        --exclude-vcs \
        -C "$HOME" \
        "${tar_targets[@]}"

    echo "    -> 正在上传压缩包..."
    rclone copyto "${LOCAL_ARCHIVE_PATH}" "${BACKUP_REMOTE}/${BACKUP_FILENAME}" --progress

    echo "    -> 清理本地临时文件..."
    rm "${LOCAL_ARCHIVE_PATH}"

    echo "    -> 清理云端 ${DAYS_TO_KEEP} 天前的旧备份..."
    rclone delete "${BACKUP_REMOTE}" --min-age "${DAYS_TO_KEEP}d"

    echo "--> ✅ dotfiles 备份任务完成。"
}


# 函数: 同步 MyPublic 文件夹
function sync_mypublic() {
    echo "--> [2/2] 正在开始 MyPublic 目录增量同步任务..."

    # 检查源目录是否存在
    if [ ! -d "$PUBLIC_SOURCE_DIR" ]; then
      echo "错误: 源目录 ${PUBLIC_SOURCE_DIR} 不存在！" >&2
      return 1
    fi

    local DEST_DIR="${PUBLIC_REMOTE_ROOT}MyPublic"
    local BACKUP_TIMESTAMP=$(date +'%Y-%m-%d')

    echo "    -> 同步目标: ${DEST_DIR}"
    echo "    -> 删除的文件将被移动到云端回收站: ${PUBLIC_REMOTE_ROOT}MyPublic_trash/${BACKUP_TIMESTAMP}"

    # 执行 rclone sync 命令
    rclone sync "${PUBLIC_SOURCE_DIR}" "${DEST_DIR}" \
        --progress \
        --create-empty-src-dirs \
        --backup-dir "${PUBLIC_REMOTE_ROOT}MyPublic_trash/${BACKUP_TIMESTAMP}"

    echo "--> ✅ MyPublic 目录同步完成。"
}


# --- 脚本主执行区 ---

# 设置时区，确保日志和时间戳正确
export TZ='Asia/Shanghai'

echo "==> [$(date)] 开始执行统一上传任务..."
echo ""

# 依次调用函数执行任务
backup_dotfiles
echo "" # 增加空行，美化输出
sync_mypublic

echo ""
echo "==> [$(date)] 所有上传任务成功完成！"

exit 0
