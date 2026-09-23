@echo off
chcp 65001 >nul
cd /d "%~dp0"

rem %~dp0 ends with a backslash; strip it so quoted paths do not break
set HERE=%~dp0
set HERE=%HERE:~0,-1%

set SERVE=%HERE%\..\tools\serve.mjs

where node >nul 2>nul
if not errorlevel 1 goto useNode
goto noNode

:useNode
node "%SERVE%" 8099 "%HERE%" --lan --open
goto stopped

:stopped
echo.
echo Server stopped. Close this window when you are done.
pause
exit /b 0

:noNode
echo.
echo Node.js was not found on this computer.
echo.
echo Two options:
echo   1. Install Node from https://nodejs.org then double-click this file again.
echo   2. Ask A-Ling for the single-file version - it needs nothing installed.
echo.
pause
exit /b 1
