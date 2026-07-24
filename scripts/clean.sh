#!/bin/bash
set -euo pipefail

# Clean build artifacts for DLC Hello Bar plugin

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Cleaning build artifacts ==="

rm -rf "${PLUGIN_DIR}/build"
rm -rf "${PLUGIN_DIR}/dist"
rm -rf "${PLUGIN_DIR}/vendor"

echo "=== Clean complete ==="
