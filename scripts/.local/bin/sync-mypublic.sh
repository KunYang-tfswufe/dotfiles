#!/bin/bash

# =====================================================================
# Public Folder Sync Script (MyPublic) - v1.0
# Uses a dedicated Google Drive remote (GDrive_2TB) as the backend.
# Files deleted locally are moved to the MyPublic_trash directory on
# the cloud for safety.
# =====================================================================

# --- Configuration ---
# 1. Absolute path to the public folder you want to sync.
SOURCE_DIR="$HOME/MyPublic"

# 2. Rclone Configuration for the 2TB Google Drive.
# Define the root of the rclone remote configuration.
RCLONE_REMOTE_ROOT="GDrive_2TB:"

# The destination directory is directly under the cloud root.
DEST_DIR="${RCLONE_REMOTE_ROOT}MyPublic"

# --- Script Main Body ---

export TZ='Asia/Shanghai'

echo ">> Starting incremental sync for public directory: ${SOURCE_DIR} (Target: GDrive_2TB)..."

# Check if the source directory exists.
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory ${SOURCE_DIR} does not exist!"
  exit 1
fi

# Define a timestamp for creating the daily backup folder.
BACKUP_TIMESTAMP=$(date +'%Y-%m-%d')

# Execute the rclone sync command with the backup-dir (cloud trash) feature.
# This provides a crucial layer of protection against accidental deletion.
rclone sync "${SOURCE_DIR}" "${DEST_DIR}" \
    --progress \
    --create-empty-src-dirs \
    --backup-dir "${RCLONE_REMOTE_ROOT}MyPublic_trash/${BACKUP_TIMESTAMP}"

if [ $? -ne 0 ]; then
  echo "Error: rclone sync failed for MyPublic!"
  exit 1
fi

echo "--> MyPublic sync complete!"
echo ">> Sync process finished!"

exit 0
