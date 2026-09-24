@echo off
chcp 65001 >nul
cd /d "%~dp0"

rem %~dp0 ends with a backslash; strip it so quoted paths do not break
set HERE=%~dp0
set HERE=%HERE:~0,-1%

rem Prefer the copy next to this file, so this folder can be shared on its own.
rem Fall back to the workspace-level tools\serve.mjs.
set SERVE=%HERE%\serve.mjs
if exist "%SERVE%" goto haveServe
set SERVE=%HERE%\..\tools\serve.mjs
if exist "%SERVE%" goto haveServe
goto noServe

:haveServe
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

:noServe
echo.
echo serve.mjs is missing next to this file, and there is no tools\serve.mjs one level up.
echo.
echo This folder looks incomplete. Easiest fix: use the single-file build -
echo the .html sitting next to this file. It needs nothing installed.
echo.
pause
exit /b 1
