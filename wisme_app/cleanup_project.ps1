# 🧹 WISME PROJECT CLEANUP SCRIPT
# Removes duplicate files and redundant analysis files while preserving ULTRA_DEEP_READINESS_ANALYSIS.md

Write-Host "Starting Wisme Project Cleanup..." -ForegroundColor Cyan
Write-Host "Working Directory: $(Get-Location)" -ForegroundColor Gray

# Verify we're in the correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERROR: Not in Flutter project root! Please navigate to wisme_app folder first." -ForegroundColor Red
    Write-Host "Expected: d:\Startups\Wisme\Development\Wisme-DevPhase1\wisme_app" -ForegroundColor Yellow
    exit 1
}

Write-Host "Confirmed: In Flutter project directory" -ForegroundColor Green

# PHASE 1: Delete duplicate and redundant files
Write-Host ""
Write-Host "PHASE 1: Removing duplicate and redundant files..." -ForegroundColor Yellow

$filesToDelete = @(
    "lib/services/auth_service.dart",
    "lib/services/smart_content_orchestrator.dart",
    "lib/providers/lesson_provider_new.dart",
    "lib/providers/user_provider.dart", 
    "lib/providers/provider_setup.dart",
    "lib/UI/screens/optimized_home_screen.dart",
    "lib/UI/screens/optimized_onboarding_screen.dart",
    "lib/UI/screens/optimized_topic_selection_screen.dart",
    "lib/user/user_manager.dart",
    "lib/user/data/user_data_service.dart",
    "lib/user/services/gamification_service.dart",
    "lib/user/services/personalization_service.dart",
    "lib/user/user_manager_v2.dart",
    "lib/user/data/user_data_service_v2.dart",
    "lib/user/services/gamification_service_v2.dart",
    "lib/user/services/personalization_service_v2.dart",
    "lib/core/initialization/app_initialization_service.dart",
    "lib/design_system/atoms/app_button.dart",
    "lib/design_system/README.md",
    "analysis.txt",
    "analysis_results.txt",
    "analysis_after_cleanup.txt"
)

$deletedCount = 0
foreach ($file in $filesToDelete) {
    if (Test-Path $file) {
        try {
            Remove-Item $file -Force
            Write-Host "   Deleted: $file" -ForegroundColor Green
            $deletedCount++
        }
        catch {
            Write-Host "   Failed to delete: $file - $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "   Not found: $file" -ForegroundColor Gray
    }
}

Write-Host "Phase 1 Complete: $deletedCount files deleted" -ForegroundColor Cyan

# PHASE 2: Rename fixed files to primary names
Write-Host ""
Write-Host "PHASE 2: Renaming fixed files to primary names..." -ForegroundColor Yellow

$filesToRename = @{
    "lib/services/smart_content_orchestrator_fixed.dart" = "lib/services/smart_content_orchestrator.dart"
    "lib/providers/user_provider_fixed.dart" = "lib/providers/user_provider.dart"
    "lib/providers/provider_setup_fixed.dart" = "lib/providers/provider_setup.dart"
    "lib/design_system/atoms/app_button_fixed.dart" = "lib/design_system/atoms/app_button.dart"
}

$renamedCount = 0
foreach ($rename in $filesToRename.GetEnumerator()) {
    if (Test-Path $rename.Key) {
        try {
            $targetDir = Split-Path $rename.Value -Parent
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            Move-Item $rename.Key $rename.Value -Force
            Write-Host "   Renamed: $($rename.Key) -> $($rename.Value)" -ForegroundColor Green
            $renamedCount++
        }
        catch {
            Write-Host "   Failed to rename: $($rename.Key) - $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "   Not found for rename: $($rename.Key)" -ForegroundColor Gray
    }
}

Write-Host "Phase 2 Complete: $renamedCount files renamed" -ForegroundColor Cyan

# PHASE 3: Check for broken imports file
Write-Host ""
Write-Host "PHASE 3: Checking imports file..." -ForegroundColor Yellow

$importsFile = "lib/imports.dart"
if (Test-Path $importsFile) {
    Write-Host "   Found lib/imports.dart - This file has syntax errors" -ForegroundColor Yellow
    Write-Host "   Recommendation: Review and fix or delete this file manually" -ForegroundColor Yellow
    Write-Host "   File location: $importsFile" -ForegroundColor Gray
} else {
    Write-Host "   No problematic imports.dart file found" -ForegroundColor Green
}

# PHASE 4: Verify critical files are preserved
Write-Host ""
Write-Host "PHASE 4: Verifying critical files are preserved..." -ForegroundColor Yellow

$criticalFiles = @(
    "ULTRA_DEEP_READINESS_ANALYSIS.md",
    "README.md",
    "pubspec.yaml",
    "lib/main.dart",
    "lib/core/exports.dart"
)

$allCriticalFilesPresent = $true
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Host "   Preserved: $file" -ForegroundColor Green
    } else {
        Write-Host "   MISSING CRITICAL FILE: $file" -ForegroundColor Red
        $allCriticalFilesPresent = $false
    }
}

# SUMMARY
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "CLEANUP SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host "Files Deleted: $deletedCount" -ForegroundColor Green
Write-Host "Files Renamed: $renamedCount" -ForegroundColor Green
Write-Host "Critical Files Preserved: $($criticalFiles.Count)" -ForegroundColor Green

if ($allCriticalFilesPresent) {
    Write-Host ""
    Write-Host "SUCCESS: Project cleanup completed successfully!" -ForegroundColor Green
    Write-Host "Your Wisme project is now streamlined and ready for development" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Run: flutter clean" -ForegroundColor White
    Write-Host "   2. Run: flutter pub get" -ForegroundColor White
    Write-Host "   3. Run: flutter analyze" -ForegroundColor White
    Write-Host "   4. Test compilation: flutter build apk --debug" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "WARNING: Some critical files are missing!" -ForegroundColor Red
    Write-Host "Please verify your project structure before proceeding." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Cleanup script completed!" -ForegroundColor Cyan
