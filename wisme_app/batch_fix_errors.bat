@echo off
echo Starting systematic error fixes...

echo Phase 1: Fixing import errors...
for /r lib\UI %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace 'import ''[^'']*_old_structure_backup/providers/user_provider\.dart'';', '// TODO: Replace with UserManager import' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace 'import ''[^'']*_old_structure_backup/providers/voice_provider\.dart'';', '// TODO: Replace with AudioManager import' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace 'import ''[^'']*_old_structure_backup/providers/coach_provider\.dart'';', '// TODO: Replace with CoachManager import' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace 'import ''[^'']*_old_structure_backup/routes\.dart'';', '// TODO: Replace with AppRouter import' | Set-Content '%%f'"
)

echo Phase 2: Fixing withOpacity calls...
for /r lib\UI %%f in (*.dart) do (
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.05\)', '.withValues(alpha: 0.05)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.1\)', '.withValues(alpha: 0.1)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.2\)', '.withValues(alpha: 0.2)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.3\)', '.withValues(alpha: 0.3)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.4\)', '.withValues(alpha: 0.4)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.5\)', '.withValues(alpha: 0.5)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.6\)', '.withValues(alpha: 0.6)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.7\)', '.withValues(alpha: 0.7)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.8\)', '.withValues(alpha: 0.8)' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace '\.withOpacity\(0\.9\)', '.withValues(alpha: 0.9)' | Set-Content '%%f'"
)

echo Phase 3: Running flutter analyze to check progress...
flutter analyze > analysis_after_batch_fix.txt 2>&1

echo DONE! Check analysis_after_batch_fix.txt for remaining errors.
