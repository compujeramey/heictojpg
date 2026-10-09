@echo off
REM ---------------------------------------------------------------
REM Install Image to JPG converter + register right-click context menu
REM Must be run as Administrator.
REM ---------------------------------------------------------------

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator.
    echo Right-click install.bat and choose "Run as administrator".
    pause
    exit /b 1
)

set "EXE_SRC=dist\image_to_jpg.exe"
set "INSTALL_DIR=C:\Program Files\ImageToJPG"
set "EXE_DEST=%INSTALL_DIR%\image_to_jpg.exe"

if not exist "%EXE_SRC%" (
    echo ERROR: %EXE_SRC% not found.
    echo Run build.bat first to create the executable.
    pause
    exit /b 1
)

echo Creating install directory...
mkdir "%INSTALL_DIR%" 2>nul

echo Copying executable...
copy /Y "%EXE_SRC%" "%EXE_DEST%"

echo Registering context menu for .heic files...
reg add "HKCR\.heic"                                           /ve /d "heicfile" /f
reg add "HKCR\heicfile\shell\ConvertToJPG"                     /ve /d "Convert to JPG" /f
reg add "HKCR\heicfile\shell\ConvertToJPG"                     /v "Icon" /d "%EXE_DEST%,0" /f
reg add "HKCR\heicfile\shell\ConvertToJPG"                     /v "MultiSelectModel" /d "Player" /f
reg add "HKCR\heicfile\shell\ConvertToJPG\command"             /ve /d "\"%EXE_DEST%\" \"%%1\"" /f

echo Registering context menu for .heif files...
reg add "HKCR\.heif"                                           /ve /d "heiffile" /f
reg add "HKCR\heiffile\shell\ConvertToJPG"                     /ve /d "Convert to JPG" /f
reg add "HKCR\heiffile\shell\ConvertToJPG"                     /v "Icon" /d "%EXE_DEST%,0" /f
reg add "HKCR\heiffile\shell\ConvertToJPG"                     /v "MultiSelectModel" /d "Player" /f
reg add "HKCR\heiffile\shell\ConvertToJPG\command"             /ve /d "\"%EXE_DEST%\" \"%%1\"" /f

echo Registering context menu for .webp files...
reg add "HKCR\SystemFileAssociations\.webp\shell\ConvertToJPG"         /ve /d "Convert to JPG" /f
reg add "HKCR\SystemFileAssociations\.webp\shell\ConvertToJPG"         /v "Icon" /d "%EXE_DEST%,0" /f
reg add "HKCR\SystemFileAssociations\.webp\shell\ConvertToJPG"         /v "MultiSelectModel" /d "Player" /f
reg add "HKCR\SystemFileAssociations\.webp\shell\ConvertToJPG\command" /ve /d "\"%EXE_DEST%\" \"%%1\"" /f

echo Registering context menu for .png files...
reg add "HKCR\SystemFileAssociations\.png\shell\ConvertToJPG"          /ve /d "Convert to JPG" /f
reg add "HKCR\SystemFileAssociations\.png\shell\ConvertToJPG"          /v "Icon" /d "%EXE_DEST%,0" /f
reg add "HKCR\SystemFileAssociations\.png\shell\ConvertToJPG"          /v "MultiSelectModel" /d "Player" /f
reg add "HKCR\SystemFileAssociations\.png\shell\ConvertToJPG\command"  /ve /d "\"%EXE_DEST%\" \"%%1\"" /f

echo Registering context menu for .pdf files...
reg add "HKCR\SystemFileAssociations\.pdf\shell\ConvertToJPG"          /ve /d "Convert to JPG" /f
reg add "HKCR\SystemFileAssociations\.pdf\shell\ConvertToJPG"          /v "Icon" /d "%EXE_DEST%,0" /f
reg add "HKCR\SystemFileAssociations\.pdf\shell\ConvertToJPG"          /v "MultiSelectModel" /d "Player" /f
reg add "HKCR\SystemFileAssociations\.pdf\shell\ConvertToJPG\command"  /ve /d "\"%EXE_DEST%\" \"%%1\"" /f

echo.
echo Installation complete.
echo Right-click any .heic, .heif, .webp, .png, or .pdf file - or select several - and choose "Convert to JPG".
pause
