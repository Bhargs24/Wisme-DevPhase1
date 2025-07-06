#!/usr/bin/env pwsh

# Fix ContentManager return types systematically
$filePath = "lib\content\content_manager.dart"

Write-Host "Fixing ContentManager return types..." -ForegroundColor Yellow

# Read the file content
$content = Get-Content $filePath -Raw

# Fix return statements that need Result wrapping
$content = $content -replace 'return await _dataService\.updateContentItem\(item\);', 'await _dataService.updateContentItem(item); return Result.success(null);'
$content = $content -replace 'return await _dataService\.deleteContentItem\(contentId\);', 'await _dataService.deleteContentItem(contentId); return Result.success(null);'
$content = $content -replace 'return await _dataService\.getContentByCategory\(category\);', 'final result = await _dataService.getContentByCategory(category); return Result.success(result);'
$content = $content -replace 'return await _dataService\.getRecommendations\(userId\);', 'final result = await _dataService.getRecommendations(userId); return Result.success(result);'

# Fix searchContent call
$content = $content -replace 'return await _dataService\.searchContent\(query\);', 'final result = await _dataService.searchContent(query: query); return Result.success(result);'

# Fix ServiceException to ContentException
$content = $content -replace 'ServiceException', 'ContentException'

# Write back to file
Set-Content -Path $filePath -Value $content

Write-Host "✅ Fixed ContentManager return types" -ForegroundColor Green
