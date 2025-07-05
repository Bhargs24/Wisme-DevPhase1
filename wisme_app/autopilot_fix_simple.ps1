#!/usr/bin/env pwsh

# AUTOPILOT ERROR FIXING SCRIPT - FIXED VERSION
Write-Host "🤖 AUTOPILOT MODE: Fixing Flutter errors systematically..." -ForegroundColor Cyan

# Get all Dart files with errors from analysis
$uiFiles = Get-ChildItem -Path "lib\UI" -Recurse -Filter "*.dart"

Write-Host "📊 Found $($uiFiles.Count) UI files to process" -ForegroundColor Yellow

# Phase 1: Fix import errors
Write-Host "`n🔧 PHASE 1: Fixing import errors..." -ForegroundColor Cyan

foreach ($file in $uiFiles) {
    $content = Get-Content $file.FullName -Raw
    $updated = $false
    
    if ($content -contains "_old_structure_backup") {
        Write-Host "  Fixing imports in $($file.Name)" -ForegroundColor Yellow
        
        # Replace problematic imports with comments
        $content = $content -replace "import '[^']*_old_structure_backup/providers/user_provider\.dart';", "// TODO: Replace with UserManager import"
        $content = $content -replace "import '[^']*_old_structure_backup/providers/voice_provider\.dart';", "// TODO: Replace with AudioManager import"  
        $content = $content -replace "import '[^']*_old_structure_backup/providers/coach_provider\.dart';", "// TODO: Replace with CoachManager import"
        $content = $content -replace "import '[^']*_old_structure_backup/services/offline_service\.dart';", "import '../../core/offline/offline_service.dart';"
        $content = $content -replace "import '[^']*_old_structure_backup/services/analytics_service\.dart';", "// TODO: Replace with AnalyticsManager import"
        $content = $content -replace "import '[^']*_old_structure_backup/routes\.dart';", "// TODO: Replace with AppRouter import"
        
        $updated = $true
    }
    
    if ($updated) {
        Set-Content -Path $file.FullName -Value $content
        Write-Host "    ✅ Fixed imports in $($file.Name)" -ForegroundColor Green
    }
}

# Phase 2: Fix deprecated withOpacity calls
Write-Host "`n🔧 PHASE 2: Fixing deprecated withOpacity calls..." -ForegroundColor Cyan

foreach ($file in $uiFiles) {
    $content = Get-Content $file.FullName -Raw
    $updated = $false
    
    if ($content -match "\.withOpacity\(") {
        Write-Host "  Fixing withOpacity in $($file.Name)" -ForegroundColor Yellow
        $content = $content -replace "\.withOpacity\(([^)]+)\)", ".withValues(alpha: `$1)"
        $updated = $true
    }
    
    if ($updated) {
        Set-Content -Path $file.FullName -Value $content
        Write-Host "    ✅ Fixed withOpacity in $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`n🎉 PHASE 1-2 COMPLETE!" -ForegroundColor Green
Write-Host "📊 Running flutter analyze to check progress..." -ForegroundColor Cyan

# Check progress
flutter analyze > analysis_results_phase2.txt 2>&1
Write-Host "✅ Results saved to analysis_results_phase2.txt" -ForegroundColor Green
