@echo off
REM Set Java 17 environment
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%

echo Java Version:
java -version
echo.

echo Starting Wisme App for Android...
flutter run -d android

pause
