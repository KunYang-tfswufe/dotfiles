#!/bin/bash

# ================= 配置区域 =================
DEVICE_PARTITION="/dev/sdb1"   # 硬盘分区 (建议后续改为 /dev/disk/by-label/... 以防变动)
DRIVE_LABEL="MyPassport"       # 硬盘标签

# ================= 系统变量 =================
CURRENT_USER=$(whoami)
MOUNT_POINT="/run/media/$CURRENT_USER/$DRIVE_LABEL"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
TRASH_DIR_ROOT="$MOUNT_POINT/.Trash_Bin/$TIMESTAMP"

echo "=== 🛡️ 混合策略备份 + 自动卸载 ==="
echo "    📅 时间戳: $TIMESTAMP"

# --- 1. 挂载检查 ---
if [ ! -d "$MOUNT_POINT" ]; then
    echo "⚠️  未检测到挂载点，尝试自动挂载 $DEVICE_PARTITION ..."
    udisksctl mount -b "$DEVICE_PARTITION"
    if [ ! -d "$MOUNT_POINT" ]; then
        echo "❌ 挂载失败！请检查设备连接。"
        exit 1
    fi
else
    echo "✅ 硬盘已就绪: $MOUNT_POINT"
fi

echo "🗑️  后悔药机制: 被删/改的文件 -> .Trash_Bin/$TIMESTAMP"
echo ""

# --- 2. 核心同步函数 ---
sync_task() {
    local SRC="$1"
    local DEST_NAME="$2"
    local SPECIAL_FLAGS="$3"
    local FULL_DEST="$MOUNT_POINT/$DEST_NAME"
    local BACKUP_DIR="$TRASH_DIR_ROOT/$DEST_NAME"

    # 检查源目录是否存在，不存在则跳过，防止报错
    if [ ! -d "$SRC" ]; then
        echo "⚠️  [跳过] 源目录不存在: $(basename "$SRC")"
        echo "-----------------------------------------------------"
        return
    fi

    echo "🔄 [同步中] $(basename "$SRC")"
    
    # 基础参数: --fast-list(加速), --delete-during(同步删除), --backup-dir(回收站)
    # 核心排除: --exclude ".git/" (排除git文件夹)
    rclone sync "$SRC" "$FULL_DEST" \
        --progress \
        --transfers 32 \
        --checkers 32 \
        --fast-list \
        --backup-dir "$BACKUP_DIR" \
        --create-empty-src-dirs \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db" \
        --exclude ".git/" \
        $SPECIAL_FLAGS

    if [ $? -eq 0 ]; then
        echo "✅ [完成] $DEST_NAME"
    else
        echo "❌ [失败] $DEST_NAME"
    fi
    echo "-----------------------------------------------------"
}

# ================= 3. 执行任务 =================

# 🎵 任务 A: 音乐库 (极速模式)
sync_task "$HOME/Music" "Music_Backup" "--size-only"

# 📄 任务 B: 文档库 (安全模式, 完整备份)
sync_task "$HOME/MyPublic" "MyPublic_Backup" "--modify-window 2s"

# ⚙️ 任务 C: Dotfiles (安全模式, 完整备份)
sync_task "$HOME/dotfiles" "dotfiles_Backup" "--modify-window 2s"

# 🎓 任务 D: fyp 项目 (已修正路径，且排除 .git)
sync_task "$HOME/fyp" "fyp_Backup" "--modify-window 2s"

# ================= 4. 清理与同步 =================
echo "🧹 清理空目录..."
rmdir --ignore-fail-on-non-empty -p "$TRASH_DIR_ROOT"/* 2>/dev/null
rmdir --ignore-fail-on-non-empty "$TRASH_DIR_ROOT" 2>/dev/null

echo "💾 正在强制写入磁盘 (Syncing)..."
sync

# ================= 5. 自动卸载与断电 =================
echo "-----------------------------------------------------"
echo "⏏️  [自动卸载] 正在尝试卸载硬盘..."

if [[ "$PWD" == *"$MOUNT_POINT"* ]]; then
    echo "⚠️  检测到当前终端位于硬盘目录内，尝试切换回主目录..."
    cd "$HOME" || exit
fi

if udisksctl unmount -b "$DEVICE_PARTITION"; then
    echo "✅ 卸载成功！"
    echo "🔌 [自动断电] 正在让硬盘停转 (安全拔出模式)..."
    PARENT_DISK="${DEVICE_PARTITION%[0-9]*}"
    
    if udisksctl power-off -b "$PARENT_DISK"; then
        echo ""
        echo "🎉🎉🎉 硬盘已安全断电，指示灯熄灭后请拔出。"
    else
        echo "🎉 硬盘已卸载 (断电命令未生效，仍可安全拔出)。"
    fi
else
    echo "❌ 卸载失败！硬盘正被占用。"
    lsof +D "$MOUNT_POINT"
fi
