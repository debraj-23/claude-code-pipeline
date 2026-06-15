#!/usr/bin/env bash
set -e

echo "============================================================"
echo " Grails UI Demo - Setup Script (Linux/macOS)"
echo "============================================================"
echo

# Check Java
if ! command -v java &>/dev/null; then
  echo "ERROR: Java not found. Install Java 17+ and retry."
  exit 1
fi
echo "[OK] Java found: $(java -version 2>&1 | head -1)"

# Download gradle-wrapper.jar
WRAPPER_JAR="gradle/wrapper/gradle-wrapper.jar"
if [ ! -f "$WRAPPER_JAR" ]; then
  echo
  echo "Downloading gradle-wrapper.jar..."
  mkdir -p gradle/wrapper
  curl -fsSL \
    "https://github.com/gradle/gradle/raw/v8.5.0/gradle/wrapper/gradle-wrapper.jar" \
    -o "$WRAPPER_JAR"
  echo "[OK] gradle-wrapper.jar downloaded."
else
  echo "[OK] gradle-wrapper.jar already present."
fi

chmod +x gradlew

echo
echo "============================================================"
echo " Setup complete!  Run the app with:"
echo "   ./gradlew bootRun"
echo
echo " Then open: http://localhost:8080"
echo "============================================================"
