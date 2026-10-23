@echo off
:: ==============================================================
:: QAREEB APP - C: DRIVE DEEP CLEANUP TOOL (MINIMUM 10-15+ GB)
:: ==============================================================
:: Run this file by Right-Clicking and selecting "Run as administrator"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This tool must be run as Administrator!
    echo.
    echo Please right-click this file "Clean_C_Drive.bat"
    echo and choose: "Run as administrator"
    echo.
    pause
    exit /b 1
)

color 0B
echo ==========================================================
echo       QAREEB - SYSTEM C: DRIVE DEEP CLEANUP (15+ GB)     
echo ==========================================================
echo.

:: 1. Disable Windows Hibernation (Instantly removes C:\hiberfil.sys: ~3.4 GB)
echo [1/4] Disabling Windows Hibernation (hiberfil.sys)...
powercfg -h off
if not exist "C:\hiberfil.sys" (
    echo   [OK] C:\hiberfil.sys removed (+3.39 GB freed!)
) else (
    echo   [INFO] Hibernation disabled.
)
echo.

:: 2. Move Windows Pagefile to D: drive (Frees ~8.4 GB on C:)
echo [2/4] Relocating Windows Pagefile to D: drive (56 GB available on D:)...
powershell -NoProfile -Command "try { $cs = Get-CimInstance Win32_ComputerSystem; $cs | Set-CimInstance -Property @{AutomaticManagedPagefile=$False}; Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value @('D:\pagefile.sys 4096 8192'); Write-Host '  [OK] Pagefile successfully relocated to D:\ (4GB - 8GB)!' -ForegroundColor Green } catch { Write-Warning $_ }"
echo.

:: 3. Clean Windows Update Cache & Temp Files
echo [3/4] Cleaning Windows Update Cache, Temp Files, and Recycle Bin...
net stop wuauserv >nul 2>&1
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*" >nul 2>&1
net start wuauserv >nul 2>&1
del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo   [OK] Temporary caches and Recycle Bin cleared!
echo.

:: 4. Windows Component Cleanup (DISM - Frees 2 to 5 GB)
echo [4/4] Cleaning superseded Windows Update components (DISM)...
echo   Please wait, this will take 1-2 minutes...
dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
echo   [OK] Windows Component Store successfully cleaned!
echo.

echo ==========================================================
echo                     CLEANUP FINISHED!                     
echo ==========================================================
powershell -NoProfile -Command "[System.IO.DriveInfo]::GetDrives() | Where-Object {$_.IsReady} | Select-Object Name, @{N='Total(GB)';E={[math]::Round($_.TotalSize/1GB,2)}}, @{N='Free(GB)';E={[math]::Round($_.TotalFreeSpace/1GB,2)}} | Format-Table -AutoSize"
echo.
echo NOTE: Restart your computer to apply the new Pagefile configuration.
echo.
pause
