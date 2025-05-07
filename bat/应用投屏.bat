@echo off
setlocal enabledelayedexpansion

:: 默认IP前缀
set "DEFAULT_PREFIX=192.168."

:: 改进的设备检测方式
set "device_connected=0"
for /f "tokens=1 skip=1" %%a in ('adb devices') do (
    if not "%%a"=="" set "device_connected=1"
)

if %device_connected% equ 1 (
    echo 当前已连接的ADB设备：
    .\adb devices
    echo.
    choice /c 12 /n /m "请选择：[1]使用已有设备 [2]输入新IP连接"
    if !errorlevel! equ 1 (
        echo 正在启动 scrcpy...
        .\scrcpy --new-display --start-app=com.dragon.read
        goto exit_adb
    )
)

:: IP输入流程
:input_ip
set /p "user_input=请输入IP地址（格式如[192.168.1.100:42424]或缩写[1.100:42424]）: "

:: 格式检查
echo %user_input% | findstr /r ":" >nul
if %errorlevel% neq 0 (
    echo 错误：必须包含端口号（如 :42424）
    goto input_ip
)

:: 智能补全IP
echo %user_input% | findstr /r "^192\.168\." >nul
if %errorlevel% equ 0 (
    set "full_ip=%user_input%"
) else (
    set "full_ip=%DEFAULT_PREFIX%%user_input%"
)

:: 连接新设备
echo 正在连接 ADB: %full_ip%
.\adb connect %full_ip%
.\adb devices | findstr "%full_ip%" >nul
if %errorlevel% neq 0 (
    echo 错误：ADB连接失败
    pause
    exit /b 1
)

echo 正在启动 scrcpy...
.\scrcpy --new-display --start-app=com.dragon.read

:: 清理
:exit_adb
echo 正在断开 ADB 连接...
.\adb disconnect %full_ip%
pause
