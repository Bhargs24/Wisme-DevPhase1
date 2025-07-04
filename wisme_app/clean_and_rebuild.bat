@echo off
REM Set Java 17 environment
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.15.6-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%

echo Cleaning project with Java 17...
flutter clean

echo Cleaning Android Gradle cache...
cd android
gradlew clean --stop
cd ..

echo Getting Flutter dependencies...
flutter pub get

echo Project cleaned! You can now run the app.
pause
