@echo off
chcp 65001 >nul
cd /d "%~dp0"

rem %~dp0 结尾带一个反斜杠，直接放进引号里会把引号吃掉，所以去掉它
set HERE=%~dp0
set HERE=%HERE:~0,-1%

echo ============================================
echo  局域网模式：同一个 WiFi 下的别人也能打开
echo  窗口里会打印一个 http://192.168.x.x:8098/ 的地址，
echo  把它发给别人就行。关掉窗口就没了。
echo ============================================
echo.

where node >nul 2>nul
if not errorlevel 1 goto useNode
where python >nul 2>nul
if not errorlevel 1 goto usePython
where py >nul 2>nul
if not errorlevel 1 goto usePy
goto noRuntime

:useNode
echo 用 Node 起服务...
echo [这里会开浏览器，测试时跳过]
node "%HERE%\..\tools\serve.mjs" 8098 "%HERE%" --lan
goto stopped

:usePython
echo 用 Python 起服务...
echo 注意：Python 这个服务不打印局域网地址，你得自己查电脑的 IP。
echo [这里会开浏览器，测试时跳过]
python -m http.server 8098
goto stopped

:usePy
echo 用 Python 启动器起服务...
echo 注意：Python 这个服务不打印局域网地址，你得自己查电脑的 IP。
echo [这里会开浏览器，测试时跳过]
py -m http.server 8098
goto stopped

:noRuntime
echo 这台电脑上没找到 Node，也没找到 Python。
echo.
echo 两个办法：
echo   1. 装个 Node 或者 Python，再双击本文件
echo   2. 找阿零要一份单文件版，双击就能开，不用装东西
echo.
echo [跳过 pause]
exit /b 1

:stopped
echo.
echo 服务已停止，关掉这个窗口就没了。
pause
