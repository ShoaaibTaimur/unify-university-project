#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  UNIFY - Sync & Restart Everything       "
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DOCKER_BIN="docker"
if ! docker ps &>/dev/null; then
    DOCKER_BIN="sudo docker"
fi

# 1. Build CSS
echo "[1/4] Rebuilding Tailwind CSS & DaisyUI..."
npm run build:css

# 2. Compile Java sources and package WAR
echo "[2/4] Compiling Java sources & packaging WAR..."
if command -v ant &> /dev/null; then
    ant war
else
    ant war
fi

# 3. Check / Start Oracle DB Container if stopped
echo "[3/4] Checking Oracle DB Container..."
if $DOCKER_BIN ps --format '{{.Names}}' | grep -q "^unify-oracle$"; then
    echo "Container unify-oracle is running."
elif $DOCKER_BIN ps -a --format '{{.Names}}' | grep -q "^unify-oracle$"; then
    echo "Starting existing unify-oracle container..."
    $DOCKER_BIN start unify-oracle
else
    PORT="1521"
    if lsof -i:1521 &>/dev/null || ss -tulpn 2>/dev/null | grep -q ":1521 "; then
        PORT="1522"
    fi
    $DOCKER_BIN run -d \
        --name unify-oracle \
        -p ${PORT}:1521 \
        -e ORACLE_PASSWORD=oracle \
        -e APP_USER=unify \
        -e APP_USER_PASSWORD=unify \
        -v "$SCRIPT_DIR/db.sql:/container-entrypoint-initdb.d/init.sql" \
        gvenzl/oracle-free:latest
fi

# 4. Restart Apache Tomcat Server Container
echo "[4/4] Restarting Apache Tomcat with updated WAR..."
$DOCKER_BIN stop unify-tomcat 2>/dev/null || true
$DOCKER_BIN rm -f unify-tomcat 2>/dev/null || true

$DOCKER_BIN run -d \
    --name unify-tomcat \
    --net host \
    -v "$SCRIPT_DIR/dist/unify-jsp-app.war:/usr/local/tomcat/webapps/ROOT.war" \
    tomcat:9-jre11

echo ""
echo "=========================================="
echo "  SYNC COMPLETE! App Live on Tomcat       "
echo "=========================================="
echo "  URL: http://localhost:8080"
echo "=========================================="
