#!/bin/bash

# =====================================================================
# Personal Backup Script - v4 (Extendable Array)
# Easily manage directories to be backed up by modifying the BACKUP_TARGETS array.
# =====================================================================

# --- Configuration ---
# !! This is the only section that needs to be modified !!
# Add or remove absolute paths of the directories you want to back up here.
BACKUP_TARGETS=(
    "$HOME/dotfiles"
    "$HOME/SecondBrain"
    "$HOME/FinalProject"
)

# Rclone Configuration
RCLONE_REMOTE="GoogleDrive:Backups/ArchPC"
DAYS_TO_KEEP=7

# --- Script Main Body (Do not modify below this line) ---

export TZ='Asia/Shanghai'
echo ">> Starting backup process (Target: Google Drive)..."

# Dynamically check if all target directories exist
for target in "${BACKUP_TARGETS[@]}"; do
    if [ ! -d "$target" ]; then
        echo "Error: Target directory '$target' does not exist! Please check the script configuration."
        exit 1
    fi
done

# Prepare temporary filename and path
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_FILENAME="backup-${TIMESTAMP}.tar.gz"
LOCAL_ARCHIVE_PATH="/tmp/${BACKUP_FILENAME}"

echo "--> Creating archive: ${BACKUP_FILENAME}"

# Dynamically generate arguments for the tar command
tar_targets=()
for target in "${BACKUP_TARGETS[@]}"; do
    tar_targets+=("$(basename "$target")")
done

# Execute the packaging command
tar -I 'gzip --best' -cf "${LOCAL_ARCHIVE_PATH}" \
    --exclude='dotfiles/project_snapshot.txt' \
    --exclude-vcs \
    -C "$HOME" \
    "${tar_targets[@]}"

if [ $? -ne 0 ]; then
  echo "Error: Failed to create the archive!"
  exit 1
fi

echo "--> Uploading archive to ${RCLONE_REMOTE}..."
rclone copyto "${LOCAL_ARCHIVE_PATH}" "${RCLONE_REMOTE}/${BACKUP_FILENAME}" --progress

if [ $? -ne 0 ]; then
  echo "Error: rclone upload failed!"
  exit 1
fi

rm "${LOCAL_ARCHIVE_PATH}"
echo "--> Cleaning up old backups older than ${DAYS_TO_KEEP} days..."
rclone delete "${RCLONE_REMOTE}" --min-age "${DAYS_TO_KEEP}d"
echo ">> Backup complete!"

exit 0
