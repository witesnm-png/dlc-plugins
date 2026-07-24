#!/bin/bash
set -euo pipefail

# Rollback a plugin to its backup version
# Usage: ./scripts/deploy/rollback.sh <plugin-name> [WP_PATH]

PLUGIN_NAME="${1:?Usage: rollback.sh <plugin-name> [wp-path]}"
WP_PATH="${2:-/opt/bitnami/wordpress}"
WP_CLI=$(which wp 2>/dev/null || echo "/opt/bitnami/wp-cli/bin/wp")
PLUGIN_PATH="${WP_PATH}/wp-content/plugins/${PLUGIN_NAME}"
BACKUP_PATH="${PLUGIN_PATH}.bak"

echo "=== Rolling back ${PLUGIN_NAME} ==="

if [[ ! -d "${BACKUP_PATH}" ]]; then
    echo "ERROR: No backup at ${BACKUP_PATH}"
    exit 1
fi

sudo $WP_CLI plugin deactivate "${PLUGIN_NAME}" --path="${WP_PATH}" --allow-root 2>/dev/null || true
sudo rm -rf "${PLUGIN_PATH}"
sudo mv "${BACKUP_PATH}" "${PLUGIN_PATH}"
sudo $WP_CLI plugin activate "${PLUGIN_NAME}" --path="${WP_PATH}" --allow-root

echo "=== Rollback complete ==="
