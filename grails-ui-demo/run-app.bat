@echo off
echo ============================================================
echo  Starting Grails UI Demo App
echo  Gradle 9.1.0  ^|  Grails 7.0.9  ^|  Java 17
echo ============================================================
echo.

set GRADLE_HOME=C:\Users\2140521\dev-tools\gradle-9.1.0
set GRAILS_HOME=C:\Users\2140521\dev-tools\apache-grails-7.0.9-bin
set PATH=%GRADLE_HOME%\bin;%GRAILS_HOME%\bin;%PATH%

echo [INFO] GRADLE_HOME = %GRADLE_HOME%
echo [INFO] GRAILS_HOME = %GRAILS_HOME%
echo.

gradle.bat bootRun -Djavax.net.ssl.trustStoreType=WINDOWS-ROOT

pause
