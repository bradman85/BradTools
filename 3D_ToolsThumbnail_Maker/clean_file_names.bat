@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1

echo === Cleaning filenames AND directory names (recursive - bottom-up) ===

:: Get current directory
set "root=%CD%"

:: Step 1: Get all paths bottom-up via PowerShell (deepest first)
:: Escaped pipes: ^^| , and other specials
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-ChildItem '%root%' -Recurse | Sort-Object FullName -Descending | Select-Object -ExpandProperty FullName"`) do (
    set "fullpath=%%i"
    set "relpath=!fullpath:%root%\=!"
    if not "!relpath!"=="" if not "!relpath!"=="." (
        set "parent=!relpath!\.."
        call set "base=%%relpath:*=%%"
        
        :: Clean the base name with PowerShell regex (replace non-allowed chars with _)
        for /f "delims=" %%c in ('powershell -NoProfile -Command "$base = '%base%'; $clean = $base -replace '[^a-zA-Z0-9._-]', '_'; Write-Output $clean"') do set "cleaned=%%c"
        
        if not "!base!"=="!cleaned!" (
            set "newrelpath=!parent!\!cleaned!"
            call set "newfull=%%root:! =!\!newrelpath:\=\\!%%"
            if exist "!newfull!" (
                echo SKIP ^(exists^): "!relpath!" ^--^> "!cleaned!"
            ) else (
                echo RENAMING: "!relpath!" ^--^> "!newrelpath!"
                ren "!fullpath!" "!cleaned!" >nul 2>&1
                if !errorlevel! neq 0 (
                    echo ERROR renaming "!relpath!": Access denied or in use?
                )
            )
        )
    )
)

:: Step 2: Extra pass for .STL files only (force lowercase .stl extension, bottom-up)
echo.
echo === Extra pass: Forcing .stl extensions ===
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-ChildItem '%root%' -Recurse -Filter '*.STL' | Sort-Object FullName -Descending | Select-Object -ExpandProperty FullName"`) do (
    set "fullpath=%%i"
    set "relpath=!fullpath:%root%\=!"
    set "parent=!relpath!\.."
    call set "base=%%relpath:*=%%"
    
    :: Extract ext and name_no_ext
    for /f "tokens=2 delims=." %%a in ("!base!.") do set "ext=%%a"
    set "name_no_ext=!base:.!ext!=!"
    
    :: Clean name_no_ext
    for /f "delims=" %%c in ('powershell -NoProfile -Command "$name = '%name_no_ext%'; $clean = $name -replace '[^a-zA-Z0-9._-]', '_'; Write-Output $clean"') do set "cleaned_no_ext=%%c"
    
    set "new_base=!cleaned_no_ext!.stl"
    set "newrelpath=!parent!\!new_base!"
    call set "newfull=%%root:! =!\!newrelpath:\=\\!%%"
    
    if not "!base!"=="!new_base!" if not exist "!newfull!" (
        echo RENAMING STL: "!relpath!" ^--^> "!newrelpath!"
        ren "!fullpath!" "!new_base!" >nul 2>&1
        if !errorlevel! neq 0 echo ERROR: "!relpath!"
    ) else if exist "!newfull!" (
        echo SKIP STL ^(exists^): "!relpath!"
    )
)

echo.
echo === All done! Press any key to exit ===
pause >nul