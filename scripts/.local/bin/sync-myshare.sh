#!/bin/bash

# =====================================================================
# Personal Large File Sync Script (MyShare) - v5 (Google Drive with Trash)
# Uses Google Drive as the backend and re-enables the --backup-dir feature.
# Files deleted locally are moved to the MyShare_trash directory on the cloud for safety.
# =====================================================================

# --- Configuration ---
# 1. Absolute path to the large folder you want to sync.
SOURCE_DIR="$HOME/MyShare"

# 2. Rclone Configuration (!! Updated for Google Drive !!)
# Define the root of the rclone remote configuration.
RCLONE_REMOTE_ROOT="GoogleDrive:"

# The destination directory is directly under the cloud root.
DEST_DIR="${RCLONE_REMOTE_ROOT}MyShare_sync"

# --- Script Main Body ---

export TZ='Asia/Shanghai'

echo ">> Starting incremental sync for directory: ${SOURCE_DIR} (Target: Google Drive)..."

# Check if the source directory exists.
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory ${SOURCE_DIR} does not exist!"
  exit 1
fi

# ======================== START OF MODIFIED SECTION ========================
# Define a timestamp for creating the daily backup folder.
BACKUP_TIMESTAMP=$(date +'%Y-%m-%d')

# Execute the rclone sync command.
# The --backup-dir parameter is re-enabled as it is well-supported by Google Drive.
# This moves files deleted locally to a specified directory on the cloud instead of
# deleting them permanently, providing a layer of protection.
rclone sync "${SOURCE_DIR}" "${DEST_DIR}" \
    --progress \
    --create-empty-src-dirs \
    --backup-dir "${RCLONE_REMOTE_ROOT}MyShare_trash/${BACKUP_TIMESTAMP}"
# ========================= END OF MODIFIED SECTION =========================

if [ $? -ne 0 ]; then
  echo "Error: rclone sync failed!"
  exit 1
fi

echo "--> Sync complete!"
echo ">> Sync process finished!"

exit 0
