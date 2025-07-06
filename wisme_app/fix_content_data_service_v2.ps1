#!/usr/bin/env pwsh

# Fix ContentDataService systematically and carefully
$filePath = "lib\content\data\content_data_service.dart"

Write-Host "Fixing ContentDataService systematically..." -ForegroundColor Yellow

# Read the file content
$content = Get-Content $filePath -Raw

# Fix all _logger references to AppLogger
$content = $content -replace '_logger\.error\(''([^'']+)'', error: e, stackTrace: stack\)', 'AppLogger.error(''$1: $e'', e, stack)'
$content = $content -replace '_logger\.info\(''([^'']+)''\)', 'AppLogger.info(''$1'')'

# Fix DataException to ContentException
$content = $content -replace 'DataException', 'ContentException'

# Fix nullable count issues
$content = $content -replace '= typeQuery\.count;', '= typeQuery.count ?? 0;'
$content = $content -replace '= difficultyQuery\.count;', '= difficultyQuery.count ?? 0;'

# Write back to file
Set-Content -Path $filePath -Value $content

Write-Host "✅ Fixed ContentDataService systematically" -ForegroundColor Green
