@echo off
setlocal EnableDelayedExpansion

REM ������ Docker Compose �̎��s�R�}���h��ǉ�����
set SCRIPT_DIR=%CD%
set CONTAINER_DEV=dev
set LOG_FOLDER=%SCRIPT_DIR%/log
set LOG_FILE=create_dev.log

cd %SCRIPT_DIR%
REM ���O�t�H���_
if not exist %LOG_FOLDER% (
    mkdir %LOG_FOLDER%
    echo "���O�t�H���_ %LOG_FOLDER% ���쐬����܂����B"
)

echo docker-compose.yml���s��...
echo docker-compose -p %CONTAINER_DEV% up -d
docker-compose -p %CONTAINER_DEV% up -d > %LOG_FOLDER%\%LOG_FILE%

pause
endlocal
