# WISME CODEBASE CLEANUP SCRIPT
# Removes all V2 duplicates and cleans up the codebase

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   WISME CODEBASE CLEANUP SCRIPT" -ForegroundColor Cyan  
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Delete all V2 duplicate files" -ForegroundColor Yellow
Write-Host "2. Clean up any temporary files" -ForegroundColor Yellow
Write-Host "3. Verify cleanup completion" -ForegroundColor Yellow
Write-Host ""

# List of V2 files to delete
$v2Files = @(
    "lib\user\user_manager_v2.dart",
    "lib\main_v2.dart", 
    "lib\user\data\user_data_service_v2.dart",
    "lib\user\services\gamification_service_v2.dart",
    "lib\user\services\personalization_service_v2.dart",
    "lib\core\initialization\app_initialization_service_v2.dart",
    "lib\app\wisme_app_v2.dart",
    "lib\services\content_reuse_service_v2.dart"
)

Write-Host "=== STEP 1: Deleting V2 duplicate files ===" -ForegroundColor Green
Write-Host ""

foreach ($file in $v2Files) {
    if (Test-Path $file) {
        Write-Host "Deleting $file" -ForegroundColor Red
        Remove-Item $file -Force
    } else {
        Write-Host "File not found: $file" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== STEP 2: Searching for additional V2 files ===" -ForegroundColor Green
Write-Host ""

# Find any remaining V2 files
$remainingV2 = Get-ChildItem -Path "lib" -Recurse -Filter "*v2*.dart" -ErrorAction SilentlyContinue

if ($remainingV2.Count -gt 0) {
    Write-Host "Found additional V2 files:" -ForegroundColor Yellow
    foreach ($file in $remainingV2) {
        Write-Host "Deleting $($file.FullName)" -ForegroundColor Red
        Remove-Item $file.FullName -Force
    }
} else {
    Write-Host "No additional V2 files found." -ForegroundColor Green
}

Write-Host ""
Write-Host "=== STEP 3: Verification ===" -ForegroundColor Green
Write-Host ""

# Verify cleanup
$finalCheck = Get-ChildItem -Path "lib" -Recurse -Filter "*v2*.dart" -ErrorAction SilentlyContinue

if ($finalCheck.Count -eq 0) {
    Write-Host "✅ SUCCESS: All V2 files have been removed!" -ForegroundColor Green
} else {
    Write-Host "⚠️  WARNING: Some V2 files still remain:" -ForegroundColor Yellow
    foreach ($file in $finalCheck) {
        Write-Host "  - $($file.FullName)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== CLEANUP COMPLETE ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "The following core files should now be clean:" -ForegroundColor White
Write-Host "- lib\user\user_manager.dart (original)" -ForegroundColor Gray
Write-Host "- lib\user\services\auth_service.dart" -ForegroundColor Gray
Write-Host "- lib\user\services\personalization_service.dart" -ForegroundColor Gray
Write-Host "- lib\user\services\gamification_service.dart" -ForegroundColor Gray
Write-Host "- lib\user\data\user_data_service.dart" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Fix any remaining compilation errors in UserManager" -ForegroundColor White
Write-Host "2. Update imports to use the correct service classes" -ForegroundColor White
Write-Host "3. Run 'flutter pub get' and 'flutter analyze'" -ForegroundColor White
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   CLEANUP SCRIPT COMPLETED" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
