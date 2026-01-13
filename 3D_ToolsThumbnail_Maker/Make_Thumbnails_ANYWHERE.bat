@echo off
title Universal STL Thumbnail Maker - FINAL

set "SCRIPT=%~dp0make_thumbs_universal.py"

if "%~1"=="" (set "TARGET=%cd%") else (set "TARGET=%~1")
set "TARGET=%TARGET:"=%"
if "%TARGET:~-1%"=="\" set "TARGET=%TARGET:~0,-1%"

echo.
echo Generating thumbnails in:
echo %TARGET%
echo.

"D:\Program Files\Blender Foundation\Blender 4.3\blender.exe" -b --enable-autoexec --python "%SCRIPT%" -- "%TARGET%"

echo.
echo ALL DONE!
pause