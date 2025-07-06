#!/usr/bin/env pwsh

# Fix ContentManager logger issues
$filePath = "lib\content\content_manager.dart"

Write-Host "Fixing ContentManager logger issues..." -ForegroundColor Yellow

# Read the file content
$content = Get-Content $filePath -Raw

# Fix all _logger references to AppLogger
$content = $content -replace '_logger\.error\(''([^'']+)'', error: e, stackTrace: stack\)', 'AppLogger.error(''$1: $e'', e, stack)'
$content = $content -replace '_logger\.info\(''([^'']+)''\)', 'AppLogger.info(''$1'')'
$content = $content -replace '_logger\.debug\(''([^'']+)''\)', 'AppLogger.debug(''$1'')'

# Write back to file
Set-Content -Path $filePath -Value $content

Write-Host "✅ Fixed ContentManager logger issues" -ForegroundColor Green
