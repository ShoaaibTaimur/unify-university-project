#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  UNIFY - Complete 1-Click Setup Script   "
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/5] Starting Oracle DB Container via Docker..."
if sudo docker ps --format '{{.Names}}' | grep -q "^unify-oracle$"; then
    echo "Container unify-oracle already running."
else
    sudo docker rm -f unify-oracle 2>/dev/null || true
    
    PORT="1521"
    if sudo lsof -i:1521 &>/dev/null || sudo ss -tulpn | grep -q ":1521 "; then
        echo "Port 1521 occupied. Using fallback port 1522..."
        PORT="1522"
    fi

    sudo docker run -d \
        --name unify-oracle \
        -p ${PORT}:1521 \
        -e ORACLE_PASSWORD=oracle \
        -e APP_USER=unify \
        -e APP_USER_PASSWORD=unify \
        -v "$SCRIPT_DIR/db.sql:/container-entrypoint-initdb.d/init.sql" \
        gvenzl/oracle-free:latest
fi

echo "[2/5] Waiting 15s for Oracle DB initialization..."
sleep 15

echo "[3/5] Executing db.sql schema & seed script in Oracle DB..."
sudo docker exec -i unify-oracle sqlplus system/oracle@FREEPDB1 << 'EOF' 2>/dev/null || true
ALTER SESSION SET CONTAINER = FREEPDB1;
CREATE USER unify IDENTIFIED BY unify;
GRANT CONNECT, RESOURCE, DBA TO unify;
ALTER USER unify QUOTA UNLIMITED ON USERS;
EOF
sudo docker exec -i unify-oracle sqlplus unify/unify@FREEPDB1 < db.sql || true

echo "[4/5] Building Tailwind CSS..."
npm install
npm run build:css

echo "[5/5] Downloading JAR dependencies & compiling via Apache Ant..."
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
    sudo apt-get update -y && sudo apt-get install -y ant
    ant war
fi

# Auto-deploy to local Tomcat if webapps directory found
TOMCAT_WEBAPPS=""
if [ -d "/var/lib/tomcat9/webapps" ]; then
    TOMCAT_WEBAPPS="/var/lib/tomcat9/webapps"
elif [ -d "/var/lib/tomcat10/webapps" ]; then
    TOMCAT_WEBAPPS="/var/lib/tomcat10/webapps"
elif [ -d "/opt/tomcat/webapps" ]; then
    TOMCAT_WEBAPPS="/opt/tomcat/webapps"
fi

if [ -n "$TOMCAT_WEBAPPS" ]; then
    echo "Deploying WAR to Tomcat webapps at $TOMCAT_WEBAPPS..."
    sudo cp dist/unify-jsp-app.war "$TOMCAT_WEBAPPS/"
    echo "WAR deployed successfully!"
fi

echo "[6/6] Launching Apache Tomcat Server Container..."
sudo docker stop unify-tomcat 2>/dev/null || true
sudo docker rm -f unify-tomcat 2>/dev/null || true

sudo docker run -d \
    --name unify-tomcat \
    --net host \
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
