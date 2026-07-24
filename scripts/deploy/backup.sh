#!/bin/bash
set -euo pipefail

# Backup current plugin version before deployment
# Usage: ./backup.sh [WP_PATH]
# WP_PATH defaults to /var/www/html

WP_PATH="${1:-/var/www/html}"
PLUGIN_NAME="dlc-sample"
PLUGIN_PATH="${WP_PATH}/wp-content/plugins/${PLUGIN_NAME}"
BACKUP_PATH="${WP_PATH}/wp-content/plugins/${PLUGIN_NAME}.bak"

echo "=== Backing up ${PLUGIN_NAME} plugin ==="

if [[ -d "${PLUGIN_PATH}" ]]; then
    # Remove old backup if exists
    rm -rf "${BACKUP_PATH}"
    # Create backup
    cp -r "${PLUGIN_PATH}" "${BACKUP_PATH}"
    echo "Backup created: ${BACKUP_PATH}"
else
    echo "No existing plugin found at ${PLUGIN_PATH} — skipping backup (fresh install)"
fi

echo "=== Backup complete ==="
