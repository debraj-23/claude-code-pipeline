@echo off
echo ============================================================
echo  Grails UI Demo - Setup Script (Windows)
echo ============================================================
echo.

REM Check Java
java -version >NUL 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERROR: Java not found. Please install Java 17+.
    exit /B 1
)
echo [OK] Java found.

REM Download gradle-wrapper.jar using PowerShell
echo.
echo Downloading gradle-wrapper.jar...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v8.5.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'gradle\wrapper\gradle-wrapper.jar'}"

if not exist "gradle\wrapper\gradle-wrapper.jar" (
    echo ERROR: Failed to download gradle-wrapper.jar.
    echo Please download it manually from:
    echo   https://github.com/gradle/gradle/raw/v8.5.0/gradle/wrapper/gradle-wrapper.jar
    echo and place it at: gradle\wrapper\gradle-wrapper.jar
    exit /B 1
)
echo [OK] gradle-wrapper.jar downloaded.

echo.
echo ============================================================
echo  Setup complete! Run the app with:
echo    gradlew.bat bootRun
echo.
echo  Then open: http://localhost:8080
echo ============================================================
