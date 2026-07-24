#!/bin/bash
set -euo pipefail

# Local CI pipeline — runs full build + test + validate cycle
# This is the single entry point that verifies everything works

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  DLC Hello Bar — Local CI Pipeline"
echo "========================================"
echo ""

# Step 1: Clean
echo ">>> Step 1: Clean"
bash "${SCRIPT_DIR}/clean.sh"
echo ""

# Step 2: Test (syntax + structure + security checks)
echo ">>> Step 2: Test"
bash "${SCRIPT_DIR}/test.sh"
echo ""

# Step 3: Build (create distributable zip)
echo ">>> Step 3: Build"
bash "${SCRIPT_DIR}/build.sh"
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
echo "Artifacts:"
echo "  - dist/dlc-sample.zip (ready for deployment)"
echo ""
echo "Next steps:"
echo "  - Run 'scripts/docker-run.sh' to start local WordPress"
echo "  - Activate plugin and run manual E2E tests"
echo "  - Or proceed to Stage 3 (Docker staging simulation)"
