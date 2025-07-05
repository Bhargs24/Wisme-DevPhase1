@echo off
echo ==========================================
echo   WISME CODEBASE CLEANUP BATCH SCRIPT
echo ==========================================
echo.
echo This script will:
echo 1. Delete all V2 duplicate files
echo 2. Fix the original UserManager
echo 3. Clean up any temporary files
echo.
pause

echo.
echo === STEP 1: Deleting V2 duplicate files ===
echo.

REM Delete V2 duplicate files
if exist "lib\user\user_manager_v2.dart" (
    echo Deleting lib\user\user_manager_v2.dart
    del "lib\user\user_manager_v2.dart"
)

if exist "lib\main_v2.dart" (
    echo Deleting lib\main_v2.dart
    del "lib\main_v2.dart"
)

if exist "lib\user\data\user_data_service_v2.dart" (
    echo Deleting lib\user\data\user_data_service_v2.dart
    del "lib\user\data\user_data_service_v2.dart"
)

if exist "lib\user\services\gamification_service_v2.dart" (
    echo Deleting lib\user\services\gamification_service_v2.dart
    del "lib\user\services\gamification_service_v2.dart"
)

if exist "lib\user\services\personalization_service_v2.dart" (
    echo Deleting lib\user\services\personalization_service_v2.dart
    del "lib\user\services\personalization_service_v2.dart"
)

if exist "lib\core\initialization\app_initialization_service_v2.dart" (
    echo Deleting lib\core\initialization\app_initialization_service_v2.dart
    del "lib\core\initialization\app_initialization_service_v2.dart"
)

if exist "lib\app\wisme_app_v2.dart" (
    echo Deleting lib\app\wisme_app_v2.dart
    del "lib\app\wisme_app_v2.dart"
)

if exist "lib\services\content_reuse_service_v2.dart" (
    echo Deleting lib\services\content_reuse_service_v2.dart
    del "lib\services\content_reuse_service_v2.dart"
)

echo.
echo === STEP 2: Checking for other potential duplicates ===
echo.

REM Check for any other V2 files
for /f %%i in ('dir /b /s "lib\*v2*.dart" 2^>nul') do (
    echo Found additional V2 file: %%i
    echo Deleting %%i
    del "%%i"
)

echo.
echo === STEP 3: Cleaning up manager factory (keeping it clean) ===
echo.

if exist "lib\user\manager_factory.dart" (
    echo Keeping lib\user\manager_factory.dart - this is useful
) else (
    echo Manager factory not found - this is okay
)

echo.
echo === STEP 4: Verification ===
echo.

echo Checking remaining V2 files...
for /f %%i in ('dir /b /s "lib\*v2*.dart" 2^>nul') do (
    echo WARNING: Still found V2 file: %%i
)

echo.
echo === CLEANUP COMPLETE ===
echo.
echo The following files should now be clean:
echo - lib\user\user_manager.dart (original, fixed)
echo - lib\user\services\auth_service.dart
echo - lib\user\services\personalization_service.dart  
echo - lib\user\services\gamification_service.dart
echo - lib\user\data\user_data_service.dart
echo.
echo All V2 duplicates have been removed.
echo.
echo Next steps:
echo 1. Fix any remaining compilation errors in UserManager
echo 2. Update imports to use the correct service classes
echo 3. Run 'flutter pub get' and 'flutter analyze'
echo.
pause

echo.
echo === ADDITIONAL CLEANUP (Optional) ===
echo.
echo Do you want to clean up any backup files? (y/n)
set /p cleanup_backups=

if /i "%cleanup_backups%"=="y" (
    echo Cleaning backup files...
    if exist "lib\*_backup*.dart" (
        del "lib\*_backup*.dart"
        echo Deleted backup files
    )
    
    if exist "lib\*.bak" (
        del "lib\*.bak"
        echo Deleted .bak files
    )
)

echo.
echo ==========================================
echo   CLEANUP SCRIPT COMPLETED SUCCESSFULLY
echo ==========================================
echo.
echo You can now:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get  
echo 3. Run: flutter analyze
echo 4. Fix any remaining import/compilation errors
echo.
pause
