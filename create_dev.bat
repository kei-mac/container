@echo off
setlocal EnableDelayedExpansion

REM ここに Docker Compose の実行コマンドを追加する
set SCRIPT_DIR=%CD%
set CONTAINER_DEV=dev
set LOG_FOLDER=%SCRIPT_DIR%/log
set LOG_FILE=create_dev.log

cd %SCRIPT_DIR%
REM ログフォルダ
if not exist %LOG_FOLDER% (
    mkdir %LOG_FOLDER%
    echo "ログフォルダ %LOG_FOLDER% が作成されました。"
)

echo docker-compose.yml実行中...
echo docker-compose -p %CONTAINER_DEV% up -d
docker-compose -p %CONTAINER_DEV% up -d > %LOG_FOLDER%\%LOG_FILE%

pause
endlocal
