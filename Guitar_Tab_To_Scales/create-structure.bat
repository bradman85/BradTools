@echo off
setlocal EnableDelayedExpansion

echo Creating Next.js + TypeScript guitar-tab-analyzer project structure...

:: Root files
echo. > package.json
echo. > tsconfig.json
echo. > next.config.ts
echo. > postcss.config.mjs
echo. > eslint.config.mjs
echo. > .gitignore

:: src/app/
md src\app 2>nul
echo. > src\app\layout.tsx
echo. > src\app\page.tsx
echo. > src\app\globals.css
echo. > src\app\favicon.ico

:: src/app/lib/
md src\app\lib 2>nul
echo. > src\app\lib\tabAnalyzer.ts

echo.
echo Done! Directory structure created:
echo guitar-tab-analyzer/
echo ├── package.json
echo ├── tsconfig.json
echo ├── next.config.ts
echo ├── postcss.config.mjs
echo ├── eslint.config.mjs
echo ├── .gitignore
echo ├── src/
echo │   └── app/
echo │       ├── layout.tsx
echo │       ├── page.tsx
echo │       ├── globals.css
echo │       ├── favicon.ico
echo │       └── lib/
echo │           └── tabAnalyzer.ts
echo.

pause