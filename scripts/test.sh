#!/bin/bash
set -euo pipefail

# Test a single plugin or all plugins
# Usage: ./scripts/test.sh [plugin-name]
# If no plugin specified, tests all plugins

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

test_plugin() {
    local plugin="$1"
    local plugin_dir="${REPO_ROOT}/plugins/${plugin}"

    echo ""
    echo "=== Testing: ${plugin} ==="

    # PHP syntax
    if command -v php &>/dev/null; then
        while IFS= read -r -d '' file; do
            if php -l "$file" 2>&1 | grep -q "No syntax errors"; then
                PASS=$((PASS + 1))
            else
                echo "FAIL: PHP syntax error in $file"
                FAIL=$((FAIL + 1))
            fi
        done < <(find "$plugin_dir" -name "*.php" -print0)
    fi

    # JS syntax
    if command -v node &>/dev/null; then
        while IFS= read -r -d '' file; do
            if node --check "$file" 2>/dev/null; then
                PASS=$((PASS + 1))
            else
                echo "FAIL: JS syntax error in $file"
                FAIL=$((FAIL + 1))
            fi
        done < <(find "$plugin_dir" -name "*.js" -print0)
    fi

    # Plugin header check
    local main_file="${plugin_dir}/${plugin}.php"
    if [[ -f "$main_file" ]]; then
        if grep -q "Plugin Name:" "$main_file"; then
            PASS=$((PASS + 1))
        else
            echo "FAIL: Missing Plugin Name header in ${plugin}.php"
            FAIL=$((FAIL + 1))
        fi

        # ABSPATH check
        if grep -q "defined( 'ABSPATH' )" "$main_file"; then
            PASS=$((PASS + 1))
        else
            echo "FAIL: Missing ABSPATH check in ${plugin}.php"
            FAIL=$((FAIL + 1))
        fi

        # CSP compliance (no inline scripts/styles)
        if ! grep -q "wp_add_inline_script\|wp_add_inline_style" "$main_file"; then
            PASS=$((PASS + 1))
        else
            echo "FAIL: Inline scripts/styles found (CSP violation)"
            FAIL=$((FAIL + 1))
        fi
    fi
}

if [[ -n "${1:-}" ]]; then
    # Test specific plugin
    test_plugin "$1"
else
    # Test all plugins
    for plugin_dir in "${REPO_ROOT}/plugins"/*/; do
        plugin=$(basename "$plugin_dir")
        test_plugin "$plugin"
    done
fi

echo ""
echo "=== Results ==="
echo "Passed: ${PASS}"
echo "Failed: ${FAIL}"
[[ ${FAIL} -eq 0 ]] && echo "STATUS: ALL PASSED" || { echo "STATUS: FAILED"; exit 1; }
