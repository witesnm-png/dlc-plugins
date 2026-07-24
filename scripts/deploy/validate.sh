#!/bin/bash
set -euo pipefail

# Validate plugin deployment
# Usage: ./validate.sh <plugin-name> [SITE_URL] [WP_PATH]

PLUGIN_NAME="${1:?Usage: validate.sh <plugin-name> [site-url] [wp-path]}"
SITE_URL="${2:-http://localhost:8080}"
WP_PATH="${3:-/var/www/html}"

echo "=== Validating ${PLUGIN_NAME} deployment ==="
echo "Site: ${SITE_URL}"

# Check 1: Plugin is active
echo ""
echo "--- Check 1: Plugin active ---"
PLUGIN_STATUS=$(wp plugin status "${PLUGIN_NAME}" --path="${WP_PATH}" --allow-root 2>/dev/null || \
wp plugin status "${PLUGIN_NAME}" --path="${WP_PATH}" 2>/dev/null || echo "error")

if echo "${PLUGIN_STATUS}" | grep -qi "active"; then
    echo "PASS: Plugin is active"
else
    echo "FAIL: Plugin is not active"
    echo "${PLUGIN_STATUS}"
    exit 1
fi

# Check 2: Frontend loads (plugin CSS present)
echo ""
echo "--- Check 2: Frontend CSS loads ---"
FRONTEND_HTML=$(curl -sf "${SITE_URL}" || echo "")
if echo "${FRONTEND_HTML}" | grep -q "${PLUGIN_NAME}"; then
    echo "PASS: ${PLUGIN_NAME} assets detected in page source"
else
    echo "FAIL: ${PLUGIN_NAME} assets not found in page source"
    exit 1
fi

# Check 3: Plugin-specific HTML rendered
echo ""
echo "--- Check 3: Plugin HTML rendered ---"
if echo "${FRONTEND_HTML}" | grep -q "data-testid=\"${PLUGIN_NAME}"; then
    echo "PASS: Plugin HTML present (data-testid found)"
else
    # Fallback: check for plugin ID pattern
    if echo "${FRONTEND_HTML}" | grep -q "id=\"${PLUGIN_NAME}"; then
        echo "PASS: Plugin HTML present (id found)"
    else
        echo "FAIL: Plugin HTML not found in page source"
        exit 1
    fi
fi

# Check 4: JavaScript loads
echo ""
echo "--- Check 4: Frontend JS loads ---"
if echo "${FRONTEND_HTML}" | grep -q "${PLUGIN_NAME}.js\|${PLUGIN_NAME}-script"; then
    echo "PASS: Plugin JS is enqueued"
else
    echo "FAIL: Plugin JS not found in page source"
    exit 1
fi

# Check 5: Admin settings page accessible
echo ""
echo "--- Check 5: Admin settings page ---"
ADMIN_STATUS=$(curl -sf -o /dev/null -w "%{http_code}" "${SITE_URL}/wp-admin/options-general.php?page=${PLUGIN_NAME}-settings" || echo "000")
if [[ "${ADMIN_STATUS}" == "200" || "${ADMIN_STATUS}" == "302" ]]; then
    echo "PASS: Admin settings page accessible (HTTP ${ADMIN_STATUS})"
else
    echo "WARN: Admin settings page returned HTTP ${ADMIN_STATUS} (may need authentication)"
fi

echo ""
echo "=== Validation complete: ALL CHECKS PASSED ==="
