@echo off
REM ---------------------------------------------------------------
REM Build image_to_jpg.exe
REM Run this once on a Windows machine that has Python 3.10+ installed.
REM ---------------------------------------------------------------

echo Installing / upgrading required packages...
pip install --upgrade pillow pillow-heif pymupdf pyinstaller

echo.
echo Building standalone executable...
pyinstaller --onefile --noconsole --name image_to_jpg image_to_jpg.py

echo.
if exist dist\image_to_jpg.exe (
    echo Build succeeded: dist\image_to_jpg.exe
    echo.
    echo Next step: run install.bat as Administrator.
) else (
    echo Build FAILED. Check the output above for errors.
)
pause
