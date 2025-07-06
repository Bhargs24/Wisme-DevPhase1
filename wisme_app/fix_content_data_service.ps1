#!/usr/bin/env pwsh

# Fix ContentDataService errors systematically
$filePath = "lib\content\data\content_data_service.dart"

Write-Host "Fixing ContentDataService errors..." -ForegroundColor Yellow

# Read the file content
$content = Get-Content $filePath -Raw

# Fix logger calls - replace _logger with AppLogger
$content = $content -replace '_logger\.error\(([^)]+)\);', 'AppLogger.error($1);'
$content = $content -replace '_logger\.info\(([^)]+)\);', 'AppLogger.info($1);'

# Fix DataException to ContentException
$content = $content -replace 'DataException', 'ContentException'

# Fix logger error calls with named parameters
$content = $content -replace "error: e, stackTrace: stack", "e, stack"

# Fix nullable count issues
$content = $content -replace '\.count;', '.count ?? 0;'

# Write back to file
Set-Content -Path $filePath -Value $content

Write-Host "✅ Fixed ContentDataService logger and exception issues" -ForegroundColor Green
