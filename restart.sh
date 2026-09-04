#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  UNIFY - Sync & Restart Everything       "
echo "  (macOS Apple Silicon M1/M2/M3 & Linux)  "
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if command -v docker &>/dev/null; then
    DOCKER_BIN="docker"
elif command -v sudo &>/dev/null && sudo docker ps &>/dev/null; then
    DOCKER_BIN="sudo docker"
else
    echo "Error: docker CLI not found."
    exit 1
fi

if ! $DOCKER_BIN info &>/dev/null; then
    if [ "$(uname -s)" = "Darwin" ] && [ -d "/Applications/Docker.app" ]; then
        echo "Docker daemon not running. Launching Docker Desktop..."
        open -a Docker
        echo "Waiting for Docker daemon..."
        for i in {1..30}; do
            if $DOCKER_BIN info &>/dev/null; then
                break
            fi
            sleep 2
        done
    fi
fi

$DOCKER_BIN network create unify-net 2>/dev/null || true

# 1. Build CSS
echo "[1/4] Rebuilding Tailwind CSS & DaisyUI..."
npm run build:css

# 2. Compile Java sources and package WAR
echo "[2/4] Compiling Java sources & packaging WAR..."
if command -v ant &> /dev/null; then
    ant war
else
    echo "Local Ant not found. Compiling via Docker JDK builder..."
    $DOCKER_BIN run --rm \
        -v "$SCRIPT_DIR":/workspace \
        -w /workspace \
        eclipse-temurin:11-jdk \
        /bin/bash -c "mkdir -p src/main/webapp/WEB-INF/classes dist && javac -cp 'src/main/webapp/WEB-INF/lib/*' -d src/main/webapp/WEB-INF/classes \$(find src/main/java -name '*.java') && jar -cvf dist/unify-jsp-app.war -C src/main/webapp ."
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
    if lsof -i :1521 &>/dev/null 2>&1; then
        PORT="1522"
    fi
    $DOCKER_BIN run -d \
        --name unify-oracle \
        --network unify-net \
        -p ${PORT}:1521 \
        -e ORACLE_PASSWORD=oracle \
        -e APP_USER=unify \
        -e APP_USER_PASSWORD=unify \
        -v unify-oracle-data:/opt/oracle/oradata \
        -v "$SCRIPT_DIR/db.sql:/container-entrypoint-initdb.d/init.sql" \
        gvenzl/oracle-free:latest
fi

# Ensure Oracle is ready before starting Tomcat
for i in {1..30}; do
    if echo "SELECT 'DB_READY_SIGNAL' FROM DUAL;" | $DOCKER_BIN exec -i unify-oracle sqlplus -s system/oracle@FREEPDB1 2>/dev/null | grep -q "DB_READY_SIGNAL"; then
        break
    fi
    sleep 2
done

# 4. Restart Apache Tomcat Server Container
echo "[4/4] Restarting Apache Tomcat with updated WAR..."
$DOCKER_BIN stop unify-tomcat 2>/dev/null || true
$DOCKER_BIN rm -f unify-tomcat 2>/dev/null || true

$DOCKER_BIN run -d \
    --name unify-tomcat \
    --network unify-net \
    -p 8080:8080 \
    -e ORACLE_URL="jdbc:oracle:thin:@unify-oracle:1521/FREEPDB1" \
    -v "$SCRIPT_DIR/dist/unify-jsp-app.war:/usr/local/tomcat/webapps/ROOT.war" \
    tomcat:9-jre11

echo ""
echo "=========================================="
echo "  SYNC COMPLETE! App Live on Tomcat       "
echo "=========================================="
echo "  URL: http://localhost:8080"
echo "=========================================="
