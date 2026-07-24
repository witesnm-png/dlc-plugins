#!/bin/bash
set -euo pipefail

# Start WordPress Docker environment with the plugin mounted

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Starting WordPress Docker environment ==="

cd "${PLUGIN_DIR}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker first."
    exit 1
fi

# Check port availability
if lsof -i :8080 > /dev/null 2>&1 || ss -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "WARNING: Port 8080 is already in use"
    echo "Run: docker compose down (if previous instance) or choose different port"
    exit 1
fi

# Start services
docker compose up -d

# Wait for WordPress to be healthy
echo "Waiting for WordPress to start..."
RETRIES=30
until curl -sf http://localhost:8080 > /dev/null 2>&1 || [[ ${RETRIES} -eq 0 ]]; do
    RETRIES=$((RETRIES - 1))
    sleep 2
done

if [[ ${RETRIES} -eq 0 ]]; then
    echo "ERROR: WordPress did not start within 60 seconds"
    docker compose logs
    exit 1
fi

echo ""
echo "=== WordPress is running ==="
echo "URL: http://localhost:8080"
echo "Admin: http://localhost:8080/wp-admin"
echo "Plugin mounted at: /var/www/html/wp-content/plugins/dlc-sample"
echo ""
echo "To stop: docker compose down"
echo "To view logs: docker compose logs -f"
