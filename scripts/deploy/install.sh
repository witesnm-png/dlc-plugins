#!/bin/bash
set -euo pipefail

# Deploy plugin via WP-CLI
# Usage: ./install.sh [WP_PATH] [ZIP_PATH]
# WP_PATH defaults to /var/www/html
# ZIP_PATH defaults to dist/dlc-sample.zip (relative to plugin root)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

WP_PATH="${1:-/var/www/html}"
ZIP_PATH="${2:-${PLUGIN_DIR}/dist/dlc-sample.zip}"

echo "=== Deploying dlc-sample plugin ==="
echo "Target: ${WP_PATH}"
echo "Source: ${ZIP_PATH}"

# Verify zip exists
if [[ ! -f "${ZIP_PATH}" ]]; then
    echo "ERROR: Plugin zip not found at ${ZIP_PATH}"
    echo "Run scripts/build.sh first to create the zip."
    exit 1
fi

# Verify WP-CLI is available
if ! command -v wp &> /dev/null; then
    echo "ERROR: WP-CLI (wp) is not installed or not in PATH"
    exit 1
fi

# Install/update plugin
echo "Installing plugin via WP-CLI..."
wp plugin install "${ZIP_PATH}" --force --path="${WP_PATH}" --allow-root 2>/dev/null || \
wp plugin install "${ZIP_PATH}" --force --path="${WP_PATH}"

# Activate plugin
echo "Activating plugin..."
wp plugin activate dlc-sample --path="${WP_PATH}" --allow-root 2>/dev/null || \
wp plugin activate dlc-sample --path="${WP_PATH}"

echo "=== Deployment complete ==="
