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
        goto menu
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
:connect_devices
echo 正在连接 ADB: %full_ip%
.\adb connect %full_ip%
.\adb devices | findstr "%full_ip%" >nul
if %errorlevel% neq 0 (
    echo 错误：ADB连接失败，尝试验证码登录
    echo.
    choice /c 12 /n /m "请选择：[1]输入验证码连接 [2]输入新端口并验证连接"
    if !errorlevel! equ 1 (
        .\adb pair %full_ip%
    ) else if !errorlevel! equ 2 (
		set /p "user_input=请输入新的端口号 ："
		:: 直接用字符串替换，找到冒号后面的内容并替换
		for /f "tokens=1 delims=:" %%a in ("%full_ip%") do (
			set soue_ip=%%a
		)
		set full_ip = %soue_ip%:%user_input%
		.\adb pair %full_ip%
		if %errorlevel% neq 0 (
			goto connect_devices
		)
	)
)




:menu
cls
echo ============================
echo 请选择要启动的应用：
echo 0. 退出
echo 1. 英语软件
echo 2. 番茄小说
echo 3. 其他应用
echo ============================
set /p choice=请输入数字并按回车:

:: 定义基础的scrcpy命令
set SCRCPY_CMD=.\scrcpy --new-display --start-app=

if "%choice%"=="0" (
	echo 退出程序。
    goto end
) else if "%choice%"=="1" (
    echo 正在启动英语软件...
    %SCRCPY_CMD%com.shanbay.sentence
    goto end
) else if "%choice%"=="2" (
	echo 正在启动番茄小说...
    %SCRCPY_CMD%com.dragon.read
    goto end
    
) else if "%choice%"=="3" (
    echo 请输入应用的包名：
    set /p appname=应用包名：
    echo 正在启动自定义应用...
    %SCRCPY_CMD%%appname%
    goto end
) else (
    echo 输入无效，请重新选择。
    pause
    goto menu
)

:end

::echo 正在启动 scrcpy...
::.\scrcpy --new-display --start-app=com.dragon.read

:: 清理
:exit_adb
echo 正在断开 ADB 连接...
.\adb disconnect %full_ip%


choice /c 123 /n /m "请选择：[1]重新连接 [2]输入新地址 [3]退出"
    if !errorlevel! equ 1 (
        goto connect_devices
    )
	if !errorlevel! equ 2 (
        goto input_ip
    )

	
