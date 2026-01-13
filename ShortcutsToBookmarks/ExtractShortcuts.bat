@echo off
setlocal enabledelayedexpansion

:: ExtractShortcuts.bat - Extract URLs from Windows shortcuts organized by folder
:: Usage: ExtractShortcuts.bat [search_path] [output_file]

title Extract Shortcuts to Bookmarks (Organized by Folder)

:: Set default values
set "SEARCH_PATH=%USERPROFILE%\Desktop"
set "OUTPUT_FILE=ShortcutsBookmarks.html"
set "RECURSE_FLAG="

:: Parse command line arguments
if not "%~1"=="" set "SEARCH_PATH=%~1"
if not "%~2"=="" set "OUTPUT_FILE=%~2"

:: Check if PowerShell script exists in same directory
set "PS_SCRIPT=%~dp0Extract-ShortcutsToBookmarks.ps1"
if not exist "%PS_SCRIPT%" (
    echo ERROR: PowerShell script not found: Extract-ShortcutsToBookmarks.ps1
    echo Please ensure both files are in the same directory.
    pause
    exit /b 1
)

:: Display options
echo ================================================
echo    Shortcuts to Bookmarks Extractor
echo    Organized by Folder Structure
echo ================================================
echo.
echo Search Path: %SEARCH_PATH%
echo Output File: %OUTPUT_FILE%
echo.

:: Ask about recursive search
set /p "RECURSE=Search subdirectories recursively? (Y/N) [Y]: "
if /i "!RECURSE!"=="" set "RECURSE=Y"
if /i "!RECURSE!"=="Y" set "RECURSE_FLAG=-Recurse"

:: Run PowerShell script
echo.
echo Extracting shortcuts organized by folder... Please wait.
echo.

powershell -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -SearchPath "%SEARCH_PATH%" -OutputFile "%OUTPUT_FILE%" %RECURSE_FLAG%

echo.
echo Process completed!
echo.
echo Press any key to exit...
pause > nul