@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo 正在启动本地服务： http://localhost:8099/
echo 关掉这个窗口就停了。
start "" http://localhost:8099/
python -m http.server 8099
