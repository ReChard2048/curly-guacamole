@echo off
chcp 65001 >nul
cd /d "%~dp0"

rem 用法:
rem   start.bat        只有自己这台机器能开
rem   start.bat lan    同一个局域网里的人也能开（会打印别人该输入的网址）

set LAN_MODE=
if /i "%~1"=="lan" set LAN_MODE=--lan

rem 注意：%~dp0 结尾带一个反斜杠，直接放进引号里会把引号吃掉，所以先去掉
set HERE=%~dp0
set HERE=%HERE:~0,-1%

echo ============================================
if defined LAN_MODE (
  echo  局域网模式：同一个 WiFi 下的别人也能打开
) else (
  echo  本机模式：只有这台电脑能打开
  echo  要让别人也打开，用： start.bat lan
)
echo ============================================
echo.

where node >nul 2>nul
if %errorlevel%==0 (
  echo 用 Node 起服务...
  echo 关掉这个窗口服务就停了。
  echo.
  start "" http://localhost:8099/
  node "%HERE%\..\tools\serve.mjs" 8099 "%HERE%" %LAN_MODE%
  goto :stopped
)

where python >nul 2>nul
if %errorlevel%==0 (
  echo 用 Python 起服务...
  echo.
  start "" http://localhost:8099/
  if defined LAN_MODE (
    python -m http.server 8099
  ) else (
    python -m http.server 8099 --bind 127.0.0.1
  )
  goto :stopped
)

where py >nul 2>nul
if %errorlevel%==0 (
  echo 用 Python 启动器起服务...
  echo.
  start "" http://localhost:8099/
  if defined LAN_MODE (
    py -m http.server 8099
  ) else (
    py -m http.server 8099 --bind 127.0.0.1
  )
  goto :stopped
)

echo 这台电脑上没找到 Node，也没找到 Python。
echo.
echo 两个办法：
echo   1. 装个 Node（https://nodejs.org）或者 Python，再双击本文件
echo   2. 找阿零要一份「单文件版」—— 不用装任何东西，双击就能开
echo.
pause
exit /b 1

:stopped
echo.
echo 服务已停止（关掉这个窗口服务就没了）。
pause
