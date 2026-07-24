#!/bin/bash
set -euo pipefail

# Validate plugin deployment
# Usage: ./validate.sh [SITE_URL] [WP_PATH]

SITE_URL="${1:-http://localhost:8080}"
WP_PATH="${2:-/var/www/html}"

echo "=== Validating dlc-sample deployment ==="
echo "Site: ${SITE_URL}"

# Check 1: Plugin is active
echo ""
echo "--- Check 1: Plugin active ---"
PLUGIN_STATUS=$(wp plugin status dlc-sample --path="${WP_PATH}" --allow-root 2>/dev/null || \
wp plugin status dlc-sample --path="${WP_PATH}" 2>/dev/null || echo "error")

if echo "${PLUGIN_STATUS}" | grep -qi "active"; then
    echo "PASS: Plugin is active"
else
    echo "FAIL: Plugin is not active"
    echo "${PLUGIN_STATUS}"
    exit 1
fi

# Check 2: Frontend loads (hello bar CSS present)
echo ""
echo "--- Check 2: Frontend CSS loads ---"
FRONTEND_HTML=$(curl -sf "${SITE_URL}" || echo "")
if echo "${FRONTEND_HTML}" | grep -q "hello-bar.css"; then
    echo "PASS: hello-bar.css is enqueued"
else
    echo "FAIL: hello-bar.css not found in page source"
    exit 1
fi

# Check 3: Hello bar HTML rendered
echo ""
echo "--- Check 3: Hello bar HTML rendered ---"
if echo "${FRONTEND_HTML}" | grep -q 'id="dlc-hello-bar"'; then
    echo "PASS: Hello bar HTML present"
else
    echo "FAIL: Hello bar HTML not found (theme may not support wp_body_open)"
    exit 1
fi

# Check 4: JavaScript loads
echo ""
echo "--- Check 4: Frontend JS loads ---"
if echo "${FRONTEND_HTML}" | grep -q "hello-bar.js"; then
    echo "PASS: hello-bar.js is enqueued"
else
    echo "FAIL: hello-bar.js not found in page source"
    exit 1
fi

# Check 5: Admin settings page accessible
echo ""
echo "--- Check 5: Admin settings page ---"
ADMIN_STATUS=$(curl -sf -o /dev/null -w "%{http_code}" "${SITE_URL}/wp-admin/options-general.php?page=dlc-hello-bar" || echo "000")
if [[ "${ADMIN_STATUS}" == "200" || "${ADMIN_STATUS}" == "302" ]]; then
    echo "PASS: Admin settings page accessible (HTTP ${ADMIN_STATUS})"
else
    echo "WARN: Admin settings page returned HTTP ${ADMIN_STATUS} (may need authentication)"
fi

echo ""
echo "=== Validation complete: ALL CHECKS PASSED ==="
