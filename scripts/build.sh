#!/bin/bash
set -euo pipefail

# Monorepo build script — builds a single plugin by name
# Usage: ./scripts/build.sh <plugin-name> [version]
# Examples:
#   ./scripts/build.sh dlc-sample              (version from git tag or 0.0.0-dev)
#   ./scripts/build.sh dlc-sample 1.2.0        (explicit version)
#   PLUGIN_VERSION=1.2.0 ./scripts/build.sh dlc-sample

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <plugin-name> [version]"
    echo "Available plugins:"
    ls -d "${REPO_ROOT}/plugins"/*/ 2>/dev/null | xargs -I{} basename {}
    exit 1
fi

PLUGIN_NAME="$1"
PLUGIN_DIR="${REPO_ROOT}/plugins/${PLUGIN_NAME}"
BUILD_DIR="${REPO_ROOT}/build/${PLUGIN_NAME}"
DIST_DIR="${REPO_ROOT}/dist"

# Verify plugin exists
if [[ ! -d "${PLUGIN_DIR}" ]]; then
    echo "ERROR: Plugin '${PLUGIN_NAME}' not found at ${PLUGIN_DIR}"
    exit 1
fi

# Determine version: explicit arg > env var > git tag > dev
if [[ -n "${2:-}" ]]; then
    VERSION="$2"
elif [[ -n "${PLUGIN_VERSION:-}" ]]; then
    VERSION="${PLUGIN_VERSION}"
elif git describe --tags --exact-match HEAD 2>/dev/null | grep -q "^${PLUGIN_NAME}/v"; then
    VERSION="$(git describe --tags --exact-match HEAD | sed "s|^${PLUGIN_NAME}/v||")"
elif git tag -l "${PLUGIN_NAME}/v*" --sort=-version:refname | head -1 | grep -q "^${PLUGIN_NAME}/v"; then
    VERSION="$(git tag -l "${PLUGIN_NAME}/v*" --sort=-version:refname | head -1 | sed "s|^${PLUGIN_NAME}/v||")"
else
    VERSION="0.0.0-dev"
fi

echo "=== Building ${PLUGIN_NAME} v${VERSION} ==="

# Clean previous build for this plugin
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}/${PLUGIN_NAME}" "${DIST_DIR}"

# Copy plugin files (exclude dev-only files)
echo "Copying plugin files..."
rsync -a --exclude='composer.json' --exclude='composer.lock' --exclude='vendor' \
    --exclude='node_modules' --exclude='.git' --exclude='*.md' \
    "${PLUGIN_DIR}/" "${BUILD_DIR}/${PLUGIN_NAME}/"

# Inject version into main plugin file
MAIN_FILE="${BUILD_DIR}/${PLUGIN_NAME}/${PLUGIN_NAME}.php"
if [[ -f "${MAIN_FILE}" ]]; then
    echo "Injecting version: ${VERSION}"
    sed -i "s/^ \* Version:.*/ * Version: ${VERSION}/" "${MAIN_FILE}"
    # Find and replace version constant (pattern: define( 'SOMETHING_VERSION', '...' ))
    sed -i "s/define( '\([A-Z_]*VERSION\)', '[^']*' );/define( '\1', '${VERSION}' );/" "${MAIN_FILE}"

    echo "Verifying:"
    grep "Version:" "${MAIN_FILE}" | head -1
    grep "VERSION" "${MAIN_FILE}" | grep "define" | head -1
fi

# Create zip
echo "Creating zip archive..."
cd "${BUILD_DIR}"
zip -r "${DIST_DIR}/${PLUGIN_NAME}-${VERSION}.zip" "${PLUGIN_NAME}/"
cp "${DIST_DIR}/${PLUGIN_NAME}-${VERSION}.zip" "${DIST_DIR}/${PLUGIN_NAME}.zip"

echo ""
echo "=== Build complete ==="
echo "Plugin:  ${PLUGIN_NAME}"
echo "Version: ${VERSION}"
echo "Output:  dist/${PLUGIN_NAME}-${VERSION}.zip"
echo "Latest:  dist/${PLUGIN_NAME}.zip"
echo "Size:    $(du -h "${DIST_DIR}/${PLUGIN_NAME}-${VERSION}.zip" | cut -f1)"
