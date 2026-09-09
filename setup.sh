#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  UNIFY - Complete 1-Click Setup Script   "
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
        echo "Waiting for Docker daemon to initialize..."
        for i in {1..30}; do
            if $DOCKER_BIN info &>/dev/null; then
                echo "Docker daemon ready."
                break
            fi
            sleep 2
        done
    fi
fi

if ! $DOCKER_BIN info &>/dev/null; then
    echo "Error: Docker daemon is not running. Please start Docker and retry."
    exit 1
fi

$DOCKER_BIN network create unify-net 2>/dev/null || true

echo "[1/6] Starting Oracle DB Container via Docker..."
if $DOCKER_BIN ps --format '{{.Names}}' | grep -q "^unify-oracle$"; then
    echo "Container unify-oracle is already running."
elif $DOCKER_BIN ps -a --format '{{.Names}}' | grep -q "^unify-oracle$"; then
    echo "Starting existing unify-oracle container..."
    $DOCKER_BIN start unify-oracle
else
    PORT="1521"
    if lsof -i :1521 &>/dev/null 2>&1; then
        echo "Port 1521 occupied. Using fallback port 1522..."
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

echo "[2/6] Waiting for Oracle DB to initialize and open FREEPDB1..."
for i in {1..60}; do
    if echo "SELECT 'DB_READY_SIGNAL' FROM DUAL;" | $DOCKER_BIN exec -i unify-oracle sqlplus -s system/oracle@FREEPDB1 2>/dev/null | grep -q "DB_READY_SIGNAL"; then
        echo "Oracle DB is ready!"
        break
    fi
    echo -n "."
    sleep 3
done
echo ""

echo "[3/6] Ensuring db.sql schema & seed script in Oracle DB..."
$DOCKER_BIN exec -i unify-oracle sqlplus system/oracle@FREEPDB1 << 'EOF' 2>/dev/null || true
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE USER unify IDENTIFIED BY unify;
GRANT CONNECT, RESOURCE, DBA TO unify;
ALTER USER unify QUOTA UNLIMITED ON USERS;
EOF
$DOCKER_BIN exec -i unify-oracle sqlplus unify/unify@FREEPDB1 < "$SCRIPT_DIR/db.sql" || true

echo "[4/6] Building Tailwind CSS..."
npm install
npm run build:css

echo "[5/6] Downloading JAR dependencies & compiling WAR..."
LIB_DIR="$SCRIPT_DIR/src/main/webapp/WEB-INF/lib"
mkdir -p "$LIB_DIR"

if [ ! -f "$LIB_DIR/javax.servlet-api-4.0.1.jar" ]; then
    echo "Downloading javax.servlet-api-4.0.1.jar..."
    curl -sSL "https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar" -o "$LIB_DIR/javax.servlet-api-4.0.1.jar"
fi

if [ ! -f "$LIB_DIR/ojdbc8-19.3.0.0.jar" ]; then
    echo "Downloading ojdbc8-19.3.0.0.jar..."
    curl -sSL "https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc8/19.3.0.0/ojdbc8-19.3.0.0.jar" -o "$LIB_DIR/ojdbc8-19.3.0.0.jar"
fi

if [ ! -f "$LIB_DIR/jstl-1.2.jar" ]; then
    echo "Downloading jstl-1.2.jar..."
    curl -sSL "https://repo1.maven.org/maven2/javax/servlet/jstl/1.2/jstl-1.2.jar" -o "$LIB_DIR/jstl-1.2.jar"
fi

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

echo "[6/6] Launching Apache Tomcat Server Container..."
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
echo "  SUCCESS! App is Live on Apache Tomcat   "
echo "=========================================="
echo "  URL: http://localhost:8080"
echo ""
echo "  Default Accounts:"
echo "    Admin:   admin@unify.edu / admin123"
echo "    Teacher: teacher@unify.edu / teacher123"
echo "    CR:      cr@unify.edu / cr123"
echo "=========================================="
