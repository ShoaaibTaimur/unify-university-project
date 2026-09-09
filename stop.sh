#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  UNIFY - Stopping Project Containers     "
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if command -v docker &>/dev/null; then
    DOCKER_BIN="docker"
elif command -v sudo &>/dev/null && sudo docker ps &>/dev/null; then
    DOCKER_BIN="sudo docker"
else
    DOCKER_BIN="docker"
fi

echo "[1/3] Stopping unify-tomcat container..."
if $DOCKER_BIN ps --format '{{.Names}}' | grep -q "^unify-tomcat$"; then
    $DOCKER_BIN stop unify-tomcat
    $DOCKER_BIN rm -f unify-tomcat
    echo "unify-tomcat stopped and removed."
else
    echo "unify-tomcat not running."
fi

echo "[2/3] Stopping unify-oracle container..."
if $DOCKER_BIN ps --format '{{.Names}}' | grep -q "^unify-oracle$"; then
    $DOCKER_BIN stop unify-oracle
    echo "unify-oracle stopped."
else
    echo "unify-oracle not running."
fi

echo "[3/3] Terminating any workspace build watchers..."
pkill -f "tailwindcss.*unify-jsp-app" 2>/dev/null || true

echo ""
echo "=========================================="
echo "  ALL UNIFY SERVICES STOPPED              "
echo "=========================================="
