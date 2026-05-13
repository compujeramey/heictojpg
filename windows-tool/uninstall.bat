@echo off
REM ---------------------------------------------------------------
REM Uninstall HEIC to JPG converter
REM Must be run as Administrator.
REM ---------------------------------------------------------------

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator.
    pause
    exit /b 1
)

echo Removing context menu entries...
reg delete "HKCR\heicfile\shell\ConvertToJPG" /f 2>nul
reg delete "HKCR\heiffile\shell\ConvertToJPG" /f 2>nul

echo Removing installed files...
rmdir /S /Q "C:\Program Files\HEICtoJPG" 2>nul

echo Uninstall complete.
pause
