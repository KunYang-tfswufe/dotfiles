#!/bin/bash

# =====================================================================
# Combined Upload Script - v1.0
# Runs both the dotfiles backup and the MyPublic sync sequentially.
# This script is intended to be called by a systemd timer or a Makefile.
# =====================================================================

set -e # Exit immediately if any command fails

# Get the directory of the script itself for robustness
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "==> [$(date)] Starting combined upload process..."

echo "--> Running backup.sh..."
"$SCRIPT_DIR/backup.sh"

echo "" # Add a blank line for readability

echo "--> Running sync-mypublic.sh..."
"$SCRIPT_DIR/sync-mypublic.sh"

echo "==> [$(date)] Combined upload process finished successfully."
