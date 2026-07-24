#!/bin/bash
set -euo pipefail

# Local CI pipeline — runs full build + test + validate cycle for a plugin
# Usage: ./scripts/ci-local.sh <plugin-name>
# If no plugin specified, runs for all plugins

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="${1:-}"

echo "========================================"
echo "  Local CI Pipeline"
if [[ -n "${PLUGIN_NAME}" ]]; then
    echo "  Plugin: ${PLUGIN_NAME}"
fi
echo "========================================"
echo ""

# Step 1: Clean
echo ">>> Step 1: Clean"
bash "${SCRIPT_DIR}/clean.sh"
echo ""

# Step 2: Test (syntax + structure + security checks)
echo ">>> Step 2: Test"
if [[ -n "${PLUGIN_NAME}" ]]; then
    bash "${SCRIPT_DIR}/test.sh" "${PLUGIN_NAME}"
else
    bash "${SCRIPT_DIR}/test.sh"
fi
echo ""

# Step 3: Build (create distributable zip)
echo ">>> Step 3: Build"
if [[ -n "${PLUGIN_NAME}" ]]; then
    bash "${SCRIPT_DIR}/build.sh" "${PLUGIN_NAME}"
else
    # Build all plugins
    REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
    for plugin_dir in "${REPO_ROOT}/plugins"/*/; do
        plugin=$(basename "$plugin_dir")
        bash "${SCRIPT_DIR}/build.sh" "${plugin}"
    done
fi
echo ""

# Step 4: Validate deploy scripts syntax
echo ">>> Step 4: Deploy script syntax check"
for script in "${SCRIPT_DIR}"/deploy/*.sh; do
    if bash -n "${script}"; then
        echo "  PASS: $(basename "${script}")"
    else
        echo "  FAIL: $(basename "${script}")"
        exit 1
    fi
done
echo ""

echo "========================================"
echo "  LOCAL CI PIPELINE: ALL STEPS PASSED"
echo "========================================"
echo ""
if [[ -n "${PLUGIN_NAME}" ]]; then
    echo "Artifacts:"
    echo "  - dist/${PLUGIN_NAME}.zip (ready for deployment)"
else
    echo "All plugins built and tested successfully."
fi
echo ""
echo "Next steps:"
echo "  - Run 'docker compose up -d' to start local WordPress"
echo "  - Activate plugin and run Playwright E2E tests"
echo "  - Or proceed to Stage 3 (Docker staging simulation)"
