@echo off
setlocal enabledelayedexpansion
chcp 936 >nul 2>&1
title 网络与系统修复工具箱 v0.6.0

:: 检查管理员权限
NET FILE 1>NUL 2>NUL
if !errorlevel! equ 0 (
    set "isAdmin=1"
    goto :gotAdmin
) else (
    set "isAdmin=0"
    goto :CheckAdminChoice
)

:CheckAdminChoice
title 网络与系统修复工具箱 v0.6.0 - 运行模式
cls
echo ==========================================
echo 网络与系统修复工具箱 v0.6.0
echo ==========================================
echo [1] 管理员模式 (修复网络/重置协议等需要)
echo [2] 普通模式 (仅限查看信息和无需权限操作)
echo [Q] 退出
echo ==========================================
choice /C 12Q /N /M "请选择运行模式："
if errorlevel 3 goto End
if errorlevel 2 goto NormalMode
if errorlevel 1 goto getAdmin

:getAdmin
echo 正在请求管理员权限...
powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit

:NormalMode
goto gotAdmin

:RequestAdminFromMenu
if "!isAdmin!"=="1" (
    echo 当前已处于管理员模式，无需重复请求。
    timeout /t 2 /nobreak >nul
    goto gotAdmin
)
echo 正在请求管理员权限...
powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit

:gotAdmin
title 网络与系统修复工具箱 v0.6.0
cls
echo ==========================================
echo 网络与系统修复工具箱 v0.6.0
echo ==========================================
if "!isAdmin!"=="1" (
    echo [1] 系统修复工具 [已提权]
) else (
    echo [1] 系统修复工具 [需管理员]
)
echo [2] 网络修复工具
echo [3] 常用工具
echo [4] 特殊工具
if "!isAdmin!"=="1" (
    echo [A] 当前已是管理员
) else (
    echo [A] 请求管理员权限
)
echo [Q] 退出
echo ==========================================
choice /C 1234AQ /N /M "请选择功能类别："
if errorlevel 6 goto End
if errorlevel 5 goto RequestAdminFromMenu
if errorlevel 4 goto SpecialToolsMenu
if errorlevel 3 goto CommonToolsMenu
if errorlevel 2 goto NetworkMenu
if errorlevel 1 goto SystemMenu

:SystemMenu
cls
echo ==========================================
echo 系统修复工具
echo ==========================================
echo [1] 启动explorer（重启资源管理器） [需管理员]
echo [2] CMD（管理员权限） [需管理员]
echo [3] 安全软件
echo [4] Windows 更新管理 [需管理员]
echo [B] 返回主菜单
echo ==========================================
choice /C 1234B /N /M "请输入选项："
if errorlevel 5 goto gotAdmin
if errorlevel 4 goto WindowsUpdateMenu
if errorlevel 3 goto SecurityMenu
if errorlevel 2 goto StartAdminCMD
if errorlevel 1 goto StartExplorer

:StartExplorer
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto SystemMenu )
cls
echo ==========================================
echo 重启Windows资源管理器
echo ==========================================
echo 此操作将重启explorer.exe进程，会短暂黑屏，请勿惊慌
choice /C YN /N /M "确认重启资源管理器？[Y/N]"
if errorlevel 2 goto SystemMenu
echo 正在关闭explorer...
taskkill /im explorer.exe /f >nul 2>&1
echo 正在启动explorer...
start explorer.exe
echo 资源管理器已重启。
goto SystemMenuReturn

:StartAdminCMD
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto SystemMenu )
cls
echo ==========================================
echo CMD（管理员权限）
echo ==========================================
choice /C YN /N /M "确认以管理员权限启动命令提示符？[Y/N]"
if errorlevel 2 goto SystemMenu
echo 正在请求提权并启动...
powershell -Command "Start-Process cmd.exe -Verb RunAs" >nul 2>&1
if !errorlevel! equ 0 (
    echo 已发送提权请求，请留意弹出的UAC确认框。
) else (
    echo 启动失败。
)
goto SystemMenuReturn

:SecurityMenu
cls
echo ==========================================
echo 安全软件
echo ==========================================
echo [1] 下载并打开 360 安全卫士（在线安装包）
echo [B] 返回系统修复
echo ==========================================
choice /C 1B /N /M "请输入选项："
if errorlevel 2 goto SystemMenu
if errorlevel 1 goto Download360Safe

:Download360Safe
cls
echo ==========================================
echo 下载并打开 360 安全卫士（在线安装包）
echo ==========================================
echo 提示：将下载在线安装包到当前脚本所在目录（360_dl_tmp）并运行。
echo 下载链接：https://dl.360scdn.com/inst.exe
choice /C YN /N /M "确认开始下载并运行 360 安全卫士？[Y/N]"
if errorlevel 2 goto SecurityMenu
set "URL_360=https://dl.360scdn.com/inst.exe"
set "DL_DIR_360=%~dp0360_dl_tmp"
set "DL_EXE_360=%DL_DIR_360%\inst.exe"
if exist "%DL_EXE_360%" (
    echo 检测到已下载安装包，将直接运行...
    echo 路径："%DL_EXE_360%"
    echo 提示：如需重新下载，请删除目录"%DL_DIR_360%"后再选择此功能。
    pause
    start "" "%DL_EXE_360%"
    goto SecurityMenu
)
if not exist "%DL_DIR_360%" mkdir "%DL_DIR_360%"
echo.
echo 正在下载 360 安全卫士在线安装包...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%URL_360%' -OutFile \"%DL_EXE_360%\" -UseBasicParsing"
if !errorlevel! neq 0 (
    echo.
    echo 下载失败，请检查网络或手动访问以下链接下载后运行：
    echo %URL_360%
    echo.
    echo 按任意键返回安全软件菜单...
    pause >nul
    goto SecurityMenu
)
echo.
echo 下载完成，准备运行安装程序...
timeout /t 2 /nobreak >nul
start "" "%DL_EXE_360%"
echo.
echo 已启动安装程序，如需重新下载请先删除目录"%DL_DIR_360%"。
echo 按任意键返回安全软件菜单...
pause >nul
goto SecurityMenu

:WindowsUpdateMenu
cls
echo ==========================================
echo Windows 更新管理
echo ==========================================
echo [1] 暂停 Windows 更新 (指定天数，最多35天)
echo [2] 恢复 Windows 更新 (取消指定天数的暂停状态)
echo [3] 彻底禁用自动更新 (永久生效，通过底层注册表)
echo [4] 恢复自动更新 (撤销彻底禁用策略)
echo [B] 返回系统修复
echo ==========================================
choice /C 1234B /N /M "请输入选项："
if errorlevel 5 goto SystemMenu
if errorlevel 4 goto ResumeWinUpdatePolicy
if errorlevel 3 goto DisableWinUpdatePolicy
if errorlevel 2 goto ResumeWinUpdate
if errorlevel 1 goto PauseWinUpdate

:PauseWinUpdate
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto WindowsUpdateMenu )
cls
echo ==========================================
echo 暂停 Windows 更新
echo ==========================================
echo 注意：Windows 10/11 最多允许暂停更新 35 天。
echo.
set "pause_days="
set /p "pause_days=请输入要暂停的天数 (1-35)："
if "!pause_days!"=="" goto WindowsUpdateMenu
set "pause_days=!pause_days:"=%!"
:: 纯数字验证
set "isNum=1"
for /f "delims=0123456789" %%i in ("!pause_days!") do set "isNum=0"
if "!isNum!"=="0" (
    echo 输入无效，请输入纯数字。
    pause >nul & goto PauseWinUpdate
)
:: 去除前导零，同时保留至少一个数字
:TrimZeroLoop
if "!pause_days:~0,1!"=="0" (
    set "pause_days=!pause_days:~1!"
    if "!pause_days!"=="" set "pause_days=0"
    goto TrimZeroLoop
)
:: 范围检查
if !pause_days! lss 1 set "pause_days=1"
if !pause_days! gtr 35 (
    echo 超过系统允许的最大天数(35天)，已自动设为 35 天。
    set "pause_days=35"
)
choice /C YN /N /M "确认暂停 Windows 更新 !pause_days! 天？[Y/N]"
if errorlevel 2 goto WindowsUpdateMenu
echo 正在暂停 Windows 更新...
set "PS_PAUSE_FILE=%TEMP%\pause_wu_tmp.ps1"
if exist "%PS_PAUSE_FILE%" del /f /q "%PS_PAUSE_FILE%" >nul 2>&1
> "%PS_PAUSE_FILE%" echo param([int]$Days
>> "%PS_PAUSE_FILE%" echo $d = (Get-Date).AddDays($Days)
>> "%PS_PAUSE_FILE%" echo $ft = $d.ToFileTime()
>> "%PS_PAUSE_FILE%" echo $p = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
>> "%PS_PAUSE_FILE%" echo if (!(Test-Path $p)) { New-Item -Path $p -Force ^| Out-Null }
>> "%PS_PAUSE_FILE%" echo Set-ItemProperty -Path $p -Name 'PauseQualityUpdates' -Value 1 -Type DWord -Force
>> "%PS_PAUSE_FILE%" echo Set-ItemProperty -Path $p -Name 'PauseFeatureUpdates' -Value 1 -Type DWord -Force
>> "%PS_PAUSE_FILE%" echo Set-ItemProperty -Path $p -Name 'PauseQualityUpdatesExpiryTime' -Value $ft -Type QWord -Force
>> "%PS_PAUSE_FILE%" echo Set-ItemProperty -Path $p -Name 'PauseFeatureUpdatesExpiryTime' -Value $ft -Type QWord -Force
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_PAUSE_FILE%" -Days !pause_days! >nul 2>&1
set "exec_err=!errorlevel!"
if exist "%PS_PAUSE_FILE%" del /f /q "%PS_PAUSE_FILE%" >nul 2>&1
if !exec_err! equ 0 (
    echo. & echo 已成功暂停 Windows 更新 !pause_days! 天。
) else (
    echo. & echo 暂停失败，请确认系统版本为 Win10/11 且具有管理员权限。
)
goto WindowsUpdateMenuReturn

:ResumeWinUpdate
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto WindowsUpdateMenu )
cls
echo ==========================================
echo 恢复 Windows 更新
echo ==========================================
choice /C YN /N /M "确认恢复 Windows 更新（将取消暂停状态）？[Y/N]"
if errorlevel 2 goto WindowsUpdateMenu
echo 正在恢复 Windows 更新...
set "PS_RESUME_FILE=%TEMP%\resume_wu_tmp.ps1"
if exist "%PS_RESUME_FILE%" del /f /q "%PS_RESUME_FILE%" >nul 2>&1
> "%PS_RESUME_FILE%" echo $p = 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'
>> "%PS_RESUME_FILE%" echo @('PauseQualityUpdates','PauseFeatureUpdates','PauseQualityUpdatesExpiryTime','PauseFeatureUpdatesExpiryTime') ^| ForEach-Object { Remove-ItemProperty -Path $p -Name $_ -Force -ErrorAction SilentlyContinue }
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_RESUME_FILE%" >nul 2>&1
set "exec_err=!errorlevel!"
if exist "%PS_RESUME_FILE%" del /f /q "%PS_RESUME_FILE%" >nul 2>&1
if !exec_err! equ 0 (
    echo 已成功恢复 Windows 更新。
) else (
    echo 恢复失败，请检查权限。
)
goto WindowsUpdateMenuReturn

:DisableWinUpdatePolicy
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto WindowsUpdateMenu )
cls
echo ==========================================
echo 彻底禁用自动更新
echo ==========================================
echo 提示：此操作通过直接修改底层注册表，永久关闭自动下载更新功能。
echo 注意：即使家庭版没有组策略界面，修改此注册表项依然对系统生效！
echo 这不会影响你手动打开设置去检查更新，但系统将不再自动下载和安装。
echo.
choice /C YN /N /M "确认彻底禁用自动更新？[Y/N]"
if errorlevel 2 goto WindowsUpdateMenu
echo 正在禁用自动更新策略...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 1 /f >nul 2>&1
if !errorlevel! equ 0 (
    echo. & echo 已彻底禁用自动更新。 & echo 提示：建议重启电脑以确保策略完全生效。
) else (
    echo. & echo 禁用失败，请检查是否已具有管理员权限。
)
goto WindowsUpdateMenuReturn

:ResumeWinUpdatePolicy
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto WindowsUpdateMenu )
cls
echo ==========================================
echo 恢复自动更新
echo ==========================================
choice /C YN /N /M "确认撤销禁用策略，恢复自动更新吗？[Y/N]"
if errorlevel 2 goto WindowsUpdateMenu
echo 正在恢复自动更新策略...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /f >nul 2>&1
if !errorlevel! equ 0 (
    echo 已恢复自动更新策略。
) else (
    echo 恢复失败，可能当前并没有设置禁用策略，或者没有权限。
)
goto WindowsUpdateMenuReturn

:SystemMenuReturn
echo.
echo 按任意键返回系统修复菜单...
pause >nul
goto SystemMenu

:WindowsUpdateMenuReturn
echo.
echo 按任意键返回 Windows 更新管理菜单...
pause >nul
goto WindowsUpdateMenu

:NetworkMenu
cls
echo ==========================================
echo 网络修复工具
echo ==========================================
echo [01] 创建系统还原点 [需管理员]   [02] 备份网络注册表 [需管理员]
echo [03] 恢复网络注册表 [需管理员]   [04] 快速断网重连 [需管理员]
echo [05] 忘记当前Wi-Fi [需管理员]    [06] 释放并更新IP地址
echo [07] 刷新DNS缓存并重启服务 [需管理员] [08] 重置Winsock与IP协议栈 [需管理员]
echo [09] 清除SSL证书缓存            [10] 清除ARP缓存 [需管理员]
echo [11] TCP连接修复 [需管理员]     [12] 修改MAC地址 [需管理员]
echo [13] 恢复原始MAC地址 [需管理员] [14] 调用360断网急救箱
echo [15] 调用360 LSP修复工具       [16] 一键全面修复 [需管理员]
echo [17] 网络检测工具               [18] 高级网络工具
echo [19] 打开Hosts文件 [需管理员]   [20] 重启电脑 [需管理员]
echo [21] 查看防火墙状态
echo [22] 重置代理服务器设置 [需管理员]
echo [23] 重置网络共享设置 [需管理员]
echo [24] 设置MTU值 [需管理员]
echo [25] 网络问题扫描与修复
echo [00] 返回主菜单
echo ==========================================
set "netChoice="
set /p "netChoice=请输入选项："
set "netChoice=!netChoice: =!"

if "!netChoice!"=="" (
    echo 错误：输入不能为空！请输入 00-24 之间的两位纯数字。
    timeout /t 2 /nobreak >nul
    goto NetworkMenu
)

:: 验证是否为两位数字
set "isValid=1"
set "firstOk="
set "secondOk="
if "!netChoice:~2,1!" neq "" set "isValid=0"
if "!netChoice:~1,1!" equ "" set "isValid=0"
for /l %%i in (0,1,9) do (
    if "!netChoice:~0,1!"=="%%i" set "firstOk=1"
    if "!netChoice:~1,1!"=="%%i" set "secondOk=1"
)
if not defined firstOk set "isValid=0"
if not defined secondOk set "isValid=0"

if "!isValid!"=="0" (
    echo 错误：输入无效！请输入 00-24 之间的两位纯数字。
    timeout /t 2 /nobreak >nul
    goto NetworkMenu
)

:: 去除前导零并转换为纯数字用于比较
set "tempNum=!netChoice!"
:TrimNetLeadingZero
if "!tempNum:~0,1!"=="0" set "tempNum=!tempNum:~1!" & goto TrimNetLeadingZero
if "!tempNum!"=="" set "tempNum=0"

:: 范围验证（比较数值）
if !tempNum! lss 0 (
    echo 错误：数字过小！
    timeout /t 2 /nobreak >nul
    goto NetworkMenu
)
if !tempNum! gtr 25 (
    echo 错误：数字过大！
    timeout /t 2 /nobreak >nul
    goto NetworkMenu
)

:: 路由分发（使用原始两位输入）
if "!netChoice!"=="00" goto gotAdmin
if "!netChoice!"=="01" goto CreateRestorePoint
if "!netChoice!"=="02" goto BackupReg
if "!netChoice!"=="03" goto RestoreReg
if "!netChoice!"=="04" goto QuickReconnect
if "!netChoice!"=="05" goto ForgetWiFi
if "!netChoice!"=="06" goto RenewIP
if "!netChoice!"=="07" goto FlushDNS
if "!netChoice!"=="08" goto ResetWinsock
if "!netChoice!"=="09" goto ClearSSL
if "!netChoice!"=="10" goto ClearARP
if "!netChoice!"=="11" goto RepairTCP
if "!netChoice!"=="12" goto ChangeMAC
if "!netChoice!"=="13" goto RestoreMAC
if "!netChoice!"=="14" goto NetMon360
if "!netChoice!"=="15" goto LSPFix360
if "!netChoice!"=="16" goto AllInOne
if "!netChoice!"=="17" goto NetworkCheck
if "!netChoice!"=="18" goto AdvancedMenu
if "!netChoice!"=="19" goto OpenHosts
if "!netChoice!"=="20" goto RebootPC
if "!netChoice!"=="21" goto FirewallMenu
if "!netChoice!"=="22" goto ResetProxy
if "!netChoice!"=="23" goto ResetNetworkSharing
if "!netChoice!"=="24" goto SetMTU
if "!netChoice!"=="25" goto NetworkScan

:: 兜底
echo 错误：无效选项！请重新输入。
timeout /t 2 /nobreak >nul
goto NetworkMenu

:OpenHosts
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 打开 Hosts 文件
echo ==========================================
echo 将使用记事本以管理员权限打开 Hosts 文件。
echo 路径：C:\Windows\System32\drivers\etc\hosts
choice /C YN /N /M "确认打开？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
notepad C:\Windows\System32\drivers\etc\hosts
goto NetworkMenuReturn

:CommonToolsMenu
cls
echo ==========================================
echo 常用工具
echo ==========================================
echo [1] 关机 [2] 重启 [3] 注销 [4] 休眠 [5] 关闭应用程序 [需管理员]
echo [6] 程序列表 [7] 任务管理器 [8] CMD [9] 注册表编辑器 [需管理员]
echo [0] 启动应用程序 [U] 批量修改文件后缀 [P] 应用程序
echo [D] 桌面快捷方式 [Z] ZIP解压工具 [E] 强制开启英文输入法
echo [T] 定时关机（例：1h2m3s）
echo [C] 取消关机（shutdown /a）
echo [B] 返回主菜单
echo ==========================================
choice /C 1234567890UPDZEBTC /N /M "请输入选项："
if errorlevel 18 goto CancelShutdown
if errorlevel 17 goto TimedShutdown
if errorlevel 16 goto gotAdmin
if errorlevel 15 goto ForceEnglishIME
if errorlevel 14 goto ZipExtractMenu
if errorlevel 13 goto DesktopShortcuts
if errorlevel 12 goto AppMenu
if errorlevel 11 goto BatchRename
if errorlevel 10 goto StartApp
if errorlevel 9 goto RegEdit
if errorlevel 8 goto StartCMD
if errorlevel 7 goto TaskMgr
if errorlevel 6 goto ListApps
if errorlevel 5 goto KillApp
if errorlevel 4 goto Hibernate
if errorlevel 3 goto LogOff
if errorlevel 2 goto RebootCommon
if errorlevel 1 goto ShutDown

:ShutDown
if "!isAdmin!"=="0" ( echo 普通模式下无权限。 & timeout /t 2 /nobreak >nul & goto CommonToolsMenu )
cls
echo ==========================================
echo 关机
echo ==========================================
choice /C YN /N /M "系统将立即关机并丢失未保存的数据，确认执行？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
shutdown /s /t 0
goto End

:RebootCommon
if "!isAdmin!"=="0" ( echo 普通模式下无权限。 & timeout /t 2 /nobreak >nul & goto CommonToolsMenu )
cls
echo ==========================================
echo 重启
echo ==========================================
choice /C YN /N /M "系统将立即重启并丢失未保存的数据，确认执行？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
shutdown /r /t 0
goto End

:LogOff
if "!isAdmin!"=="0" ( echo 普通模式下无权限。 & timeout /t 2 /nobreak >nul & goto CommonToolsMenu )
cls
echo ==========================================
echo 注销
echo ==========================================
choice /C YN /N /M "系统将立即注销当前用户，确认执行？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
shutdown /l
goto End

:Hibernate
if "!isAdmin!"=="0" ( echo 普通模式下无权限。 & timeout /t 2 /nobreak >nul & goto CommonToolsMenu )
cls
echo ==========================================
echo 休眠
echo ==========================================
echo 注意：如果系统未开启休眠功能，可能执行失败。
choice /C YN /N /M "系统将立即进入休眠状态，确认执行？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
shutdown /h
goto End

:KillApp
if "!isAdmin!"=="0" ( echo 普通模式下无权限。 & timeout /t 2 /nobreak >nul & goto CommonToolsMenu )
cls
echo ==========================================
echo 关闭应用程序
echo ==========================================
set /p "killProc=请输入要关闭的程序进程名(如 notepad.exe)："
if "!killProc!"=="" goto CommonToolsMenu
set "killProc=!killProc:"=%!"
set "killProc=!killProc:!=!"
choice /C YN /N /M "确认强制结束 "!killProc!" 进程？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
taskkill /im "!killProc!" /f /t >nul 2>&1
if !errorlevel! equ 0 (echo 已成功结束 "!killProc!") else (echo 结束失败，请检查进程名是否正确或是否有权限。)
goto CommonToolsReturn

:ListApps
cls
echo ==========================================
echo 程序列表
echo ==========================================
choice /C YN /N /M "将获取并显示当前运行的进程列表，确认执行？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
tasklist
goto CommonToolsReturn

:TaskMgr
cls
echo ==========================================
echo 任务管理器
echo ==========================================
choice /C YN /N /M "确认启动Windows任务管理器？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
start taskmgr.exe
goto CommonToolsReturn

:StartCMD
cls
echo ==========================================
echo CMD
echo ==========================================
choice /C YN /N /M "确认启动命令提示符？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
start cmd.exe
goto CommonToolsReturn

:RegEdit
if "!isAdmin!"=="0" ( echo 普通模式下无权限。 & timeout /t 2 /nobreak >nul & goto CommonToolsMenu )
cls
echo ==========================================
echo 注册表编辑器
echo ==========================================
choice /C YN /N /M "误操作可能导致系统崩溃，确认启动注册表编辑器？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
start regedit.exe
goto CommonToolsReturn

:StartApp
cls
echo ==========================================
echo 启动应用程序
echo ==========================================
set /p "startApp=请输入要启动的程序名称或完整路径(如 notepad 或 D:\test.exe)："
if "!startApp!"=="" goto CommonToolsMenu
set "startApp=!startApp:"=%!"
set "startApp=!startApp:!=!"
choice /C YN /N /M "确认启动 "!startApp!"？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
start "" "!startApp!"
goto CommonToolsReturn

:ForceEnglishIME
cls
echo ==========================================
echo 强制开启英文输入法
echo ==========================================
echo 正在强制切换至英文(美国)键盘布局...
set "PS_IME=%TEMP%\force_ime_tmp.ps1"
if exist "%PS_IME%" del /f /q "%PS_IME%" >nul 2>&1
> "%PS_IME%" echo $code = @'
>> "%PS_IME%" echo [DllImport("user32.dll")]
>> "%PS_IME%" echo public static extern IntPtr LoadKeyboardLayout(string pwszKLID, uint Flags);
>> "%PS_IME%" echo [DllImport("user32.dll")]
>> "%PS_IME%" echo public static extern IntPtr ActivateKeyboardLayout(IntPtr hkl, uint Flags);
>> "%PS_IME%" echo '@
>> "%PS_IME%" echo Add-Type -MemberDefinition $code -Name 'KB' -Namespace 'Win32'
>> "%PS_IME%" echo $hkl = [Win32.KB]::LoadKeyboardLayout('00000409', 1)
>> "%PS_IME%" echo $null = [Win32.KB]::ActivateKeyboardLayout($hkl, 0)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_IME%" >nul 2>&1
if exist "%PS_IME%" del /f /q "%PS_IME%" >nul 2>&1
echo 切换完成。
goto CommonToolsReturn

:DesktopShortcuts
cls
echo ==========================================
echo 桌面快捷方式启动
echo ==========================================
echo 正在获取当前活跃桌面路径...
set "RealUser="
for /f "tokens=2" %%u in ('tasklist /v /fi "imagename eq explorer.exe" /fo list 2^>nul ^| findstr /i "Username 用户名"') do (
    set "RealUser=%%u"
)
set "RealUser=!RealUser: =!"
if "!RealUser!"=="" (
    echo 无法获取当前活跃用户，尝试使用默认用户桌面...
    set "RealDesktop=%USERPROFILE%\Desktop"
) else (
    set "RealDesktop=C:\Users\!RealUser!\Desktop"
    if not exist "!RealDesktop!\*.lnk" (
        if exist "C:\Users\!RealUser!\OneDrive\桌面" (
            set "RealDesktop=C:\Users\!RealUser!\OneDrive\桌面"
        )
    )
)
echo 正在扫描桌面快捷方式...
echo.
set "lnk_count=0"
for /f "delims=" %%F in ('dir /b "!RealDesktop!\*.lnk" 2^>nul') do (
    set /a lnk_count+=1
    set "lnk[!lnk_count!]=%%F"
    set "lnk_path[!lnk_count!]=!RealDesktop!\%%F"
    echo [!lnk_count!] %%~nF
)
for /f "delims=" %%F in ('dir /b "%PUBLIC%\Desktop\*.lnk" 2^>nul') do (
    set /a lnk_count+=1
    set "lnk[!lnk_count!]=%%F"
    set "lnk_path[!lnk_count!]=%PUBLIC%\Desktop\%%F"
    echo [!lnk_count!] %%~nF [公共]
)
echo.
if !lnk_count! equ 0 (
    echo 桌面下未找到任何快捷方式。 & echo 按任意键返回... & pause >nul & goto CommonToolsMenu
)
set "sel_idx="
set /p "sel_idx=请输入要启动的快捷方式序号："
if "!sel_idx!"=="" goto CommonToolsMenu
set "sel_idx=!sel_idx:!=!"
echo(!sel_idx!| findstr /r "^[0-9]*$" >nul
if errorlevel 1 (
    echo 输入无效，请输入数字。 & pause >nul & goto DesktopShortcuts
)
set "target_lnk=!lnk[%sel_idx%]!"
if "!target_lnk!"=="" (
    echo 输入的序号无效，请重新输入。 & pause >nul & goto DesktopShortcuts
)
set "target_path=!lnk_path[%sel_idx%]!"
echo.
echo 正在启动 "!target_lnk!"...
start "" "!target_path!"
echo.
echo 按任意键继续...
pause >nul
goto DesktopShortcuts

:ZipExtractMenu
cls
echo ==========================================
echo ZIP解压工具
echo ==========================================
echo 正在扫描当前目录下的 ZIP 文件...
echo.
set "zip_count=0"
for /f "delims=" %%F in ('dir /b "%~dp0*.zip" 2^>nul') do (
    set /a zip_count+=1
    set "zip[!zip_count!]=%%F"
    echo [!zip_count!] %%F
)
echo.
if !zip_count! equ 0 (
    echo 当前目录下未找到任何 ZIP 文件。 & echo 按任意键返回... & pause >nul & goto CommonToolsMenu
)
echo 请选择解压模式：
echo [1] 直接解压到当前目录 (可能覆盖同名文件)
echo [2] 解压到以ZIP文件名为名字的文件夹 (推荐)
echo [3] 解压到指定的统一新建文件夹
echo [B] 返回
echo ==========================================
choice /C 123B /N /M "请选择模式："
if errorlevel 4 goto CommonToolsMenu
if errorlevel 3 set "extract_mode=custom" & goto ZipSelectScope
if errorlevel 2 set "extract_mode=zipname" & goto ZipSelectScope
if errorlevel 1 set "extract_mode=current" & goto ZipSelectScope

:ZipSelectScope
if "!extract_mode!"=="custom" (
    echo.
    set "custom_dir="
    set /p "custom_dir=请输入新建的文件夹名称："
    if "!custom_dir!"=="" goto ZipExtractMenu
    set "custom_dir=!custom_dir:"=%!"
    set "custom_dir=!custom_dir:!=!"
    if not exist "%~dp0!custom_dir!" mkdir "%~dp0!custom_dir!"
)
echo.
echo [A] 解压全部 (!zip_count! 个文件)
echo [S] 解压单个
echo [B] 返回
choice /C ASB /N /M "请选择范围："
if errorlevel 3 goto ZipExtractMenu
if errorlevel 2 goto ZipSelectSingle
if errorlevel 1 goto ZipExtractAll

:ZipSelectSingle
echo.
set "sel_idx="
set /p "sel_idx=请输入要解压的文件序号："
if "!sel_idx!"=="" goto ZipSelectScope
set "sel_idx=!sel_idx:!=!"
set "target_zip=!zip[%sel_idx%]!"
if "!target_zip!"=="" (
    echo 输入的序号无效，请重新输入。 & pause >nul & goto ZipSelectScope
)
echo.
call :DoExtract "!target_zip!"
echo.
echo 按任意键继续...
pause >nul
goto ZipExtractMenu

:ZipExtractAll
echo.
for /l %%i in (1, 1, !zip_count!) do (
    call :DoExtract "!zip[%%i]!"
)
echo.
echo 全部解压完成。
echo 按任意键继续...
pause >nul
goto ZipExtractMenu

:DoExtract
set "zfile=%~1"
if "!extract_mode!"=="current" (
    echo 正在解压 [!zfile!] 到当前目录...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath \"%~dp0!zfile!\" -DestinationPath \"%~dp0\" -Force" >nul 2>&1
    if !errorlevel! equ 0 (echo [!zfile!] 解压成功) else (echo [!zfile!] 解压失败)
) else if "!extract_mode!"=="zipname" (
    set "zname=!zfile:~0,-4!"
    if not exist "%~dp0!zname!" mkdir "%~dp0!zname!"
    echo 正在解压 [!zfile!] 到文件夹 [!zname!]...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath \"%~dp0!zfile!\" -DestinationPath \"%~dp0!zname!\" -Force" >nul 2>&1
    if !errorlevel! equ 0 (echo [!zfile!] 解压成功) else (echo [!zfile!] 解压失败)
) else if "!extract_mode!"=="custom" (
    echo 正在解压 [!zfile!] 到统一文件夹 [!custom_dir!]...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath \"%~dp0!zfile!\" -DestinationPath \"%~dp0!custom_dir!\" -Force" >nul 2>&1
    if !errorlevel! equ 0 (echo [!zfile!] 解压成功) else (echo [!zfile!] 解压失败)
)
exit /b

:AppMenu
cls
echo ==========================================
echo 应用程序
echo ==========================================
echo [1] 文件加密软件 Apate v1.4.2
echo [B] 返回常用工具
echo ==========================================
choice /C 1B /N /M "请输入选项："
if errorlevel 2 goto CommonToolsMenu
if errorlevel 1 goto RunApate

:RunApate
cls
echo ==========================================
echo 文件加密软件 Apate v1.4.2
echo ==========================================
set "APATE_DIR=%~dp0apate.v1.4.2"
set "APATE_EXE=%APATE_DIR%\apate.exe"
if exist "%APATE_EXE%" (
    echo 检测到已存在，正在启动 Apate...
    start "" /D "%APATE_DIR%" "%APATE_EXE%"
    goto AppMenuReturn
)
echo 未检测到 Apate。
echo.
echo 说明：Apate 是第三方文件加密软件，本工具箱不附带分发。
echo 使用方法：自行获取 Apate v1.4.2，解压后将 apate.v1.4.2 文件夹放到本脚本同一目录，
echo           使其相对路径为 apate.v1.4.2\apate.exe，再次运行本菜单即可自动识别。
echo.
goto AppMenuReturn
:AppMenuReturn
echo.
echo 按任意键返回应用程序菜单...
pause >nul
goto AppMenu

:BatchRename
cls
echo ==========================================
echo 批量文件后缀更改工具
echo ==========================================
echo [1] 移除指定后缀 (如输入 .zip 将 1.zip 变为 1)
echo [2] 添加指定后缀 (给无后缀文件添加后缀)
echo [3] 替换后缀 (如将 .zip 统一替换为 .dat)
echo [B] 返回常用工具
echo ==========================================
choice /C 123B /N /M "请输入选项："
if errorlevel 4 goto CommonToolsMenu
if errorlevel 3 goto ReplaceExt
if errorlevel 2 goto AddExt
if errorlevel 1 goto RemoveExt

:RemoveExt
cls
echo ==========================================
echo 移除指定后缀
echo ==========================================
set "old_ext="
set /p "old_ext=请输入要移除的后缀(如 .zip)："
if "!old_ext!"=="" goto BatchRename
for /f "delims=" %%a in ("!old_ext!") do set "old_ext=%%~a"

echo(!old_ext!| findstr /b "^[.]" >nul || set "old_ext=.!old_ext!"
call :DoRename "!old_ext!" "" "移除 [!old_ext!]"

goto BatchRename

:AddExt
cls
echo ==========================================
echo 添加指定后缀
echo ==========================================
echo 警告：此操作会为当前目录下所有【无后缀】的文件添加后缀！
set "new_ext="
set /p "new_ext=请输入要添加的后缀(如 .zip)："
if "!new_ext!"=="" goto BatchRename
for /f "delims=" %%a in ("!new_ext!") do set "new_ext=%%~a"
echo(!new_ext!| findstr /b "^[.]" >nul || set "new_ext=.!new_ext!"
call :DoRenameAdd "!new_ext!" "添加 [!new_ext!]"
goto BatchRename

:ReplaceExt
cls
echo ==========================================
echo 替换后缀
echo ==========================================
set "old_ext="
set /p "old_ext=请输入原后缀(如 .zip)："
if "!old_ext!"=="" goto BatchRename
set "old_ext=!old_ext:"=%!"
set "old_ext=!old_ext:!=!"
echo(!old_ext!| findstr /b "^[.]" >nul || set "old_ext=.!old_ext!"
set "new_ext="
set /p "new_ext=请输入新后缀(如 .jpg)："
if "!new_ext!"=="" goto BatchRename
set "new_ext=!new_ext:"=%!"
set "new_ext=!new_ext:!=!"
echo(!new_ext!| findstr /b "^[.]" >nul || set "new_ext=.!new_ext!"
call :DoRename "!old_ext!" "!new_ext!" "替换 [!old_ext!] 为 [!new_ext!]"
goto BatchRename

:DoRename
set "old_ext=%~1"
set "new_ext=%~2"
set "operation=%~3"
set "pattern=*!old_ext!"
set file_count=0
set skip_count=0
set success_count=0
:: 计算旧后缀长度（用于截取文件名）
set "old_ext_len=0"
set "tmp_len_str=!old_ext!"
:DoRename_CalcLen
if defined tmp_len_str (
    set "tmp_len_str=!tmp_len_str:~1!"
    set /a old_ext_len+=1
    goto DoRename_CalcLen
)
cls
echo ========================================
echo %operation%
echo ========================================
echo.
dir /b /a-d "%pattern%" >nul 2>&1
if errorlevel 1 (
    echo 错误：没有找到匹配 %pattern% 的文件！ & echo 按任意键返回... & pause >nul & goto :eof
)
echo 找到的文件：
echo ----------------------------
for /f "delims=" %%f in ('dir /b /a-d "%pattern%" 2^>nul') do (
    echo "%%~nxf" & set /a file_count+=1
)
echo ----------------------------
echo 共找到 !file_count! 个文件
echo.
set /p confirm=确认执行 %operation% 操作？[y/N]: 
if /i not "!confirm!"=="y" ( echo 操作已取消。按任意键返回... & pause >nul & goto :eof )
echo 正在执行操作...
echo.
for /f "delims=" %%f in ('dir /b /a-d "%pattern%" 2^>nul') do (
    set "original_name=%%~nxf"
    call :StripOldExt "%%~nxf"
    set "new_name=!base_name!!new_ext!"
    if "!original_name!"=="!new_name!" (
        echo 跳过：!original_name! —— 无需更改
        set /a skip_count+=1
    ) else if exist "!new_name!" (
        echo 跳过：!original_name! —— 目标文件已存在
        set /a skip_count+=1
    ) else (
        ren "!original_name!" "!new_name!" 2>nul
        if !errorlevel! equ 0 (
            echo 成功：!original_name! ---> !new_name!
            set /a success_count+=1
        ) else (
            echo 失败：!original_name! —— 重命名出错或被占用
            set /a skip_count+=1
        )
    )
)
echo.
echo ========================================
echo 操作完成！
echo 成功处理: !success_count! 个文件
if !skip_count! gtr 0 echo 跳过/失败: !skip_count! 个文件
echo ========================================
echo 按任意键返回...
pause >nul
goto :eof

:StripOldExt
set "base_name=%~1"
call set "base_name=%%base_name:~0,-%old_ext_len%%%"
goto :eof
:DoRenameAdd
set "new_ext=%~1"
set "operation=%~2"
set file_count=0
set skip_count=0
set success_count=0
cls
echo ========================================
echo %operation%
echo ========================================
echo.
echo 正在扫描无后缀文件...
echo ----------------------------
for /f "delims=" %%f in ('dir /b /a-d 2^>nul') do (
    set "ext=%%~xf"
    if "!ext!"=="" (
        echo "%%~nxf" & set /a file_count+=1
    )
)
echo ----------------------------
echo 共找到 !file_count! 个无后缀文件
echo.
if !file_count! equ 0 ( echo 没有找到无后缀文件！按任意键返回... & pause >nul & goto :eof )
set /p confirm=确认执行 %operation% 操作？[y/N]: 
if /i not "!confirm!"=="y" ( echo 操作已取消。按任意键返回... & pause >nul & goto :eof )
echo 正在执行操作...
echo.
for %%f in (*) do (
    set "original_name=%%~nxf"
    set "ext=%%~xf"
    if "!ext!"=="" (
        set "new_name=!original_name!!new_ext!"
        if exist "!new_name!" (
            echo 跳过：!original_name! —— 目标文件已存在 & set /a skip_count+=1
        ) else (
            ren "!original_name!" "!new_name!" 2>nul
            if !errorlevel! equ 0 (
                echo 成功：!original_name! ——^> !new_name! & set /a success_count+=1
            ) else (
                echo 失败：!original_name! —— 重命名出错或被占用 & set /a skip_count+=1
            )
        )
    )
)
echo.
echo ========================================
echo 操作完成！
echo 成功处理: !success_count! 个文件
if !skip_count! gtr 0 echo 跳过/失败: !skip_count! 个文件
echo ========================================
echo 按任意键返回...
pause >nul
goto :eof

:CommonToolsReturn
echo.
echo 按任意键返回常用工具菜单...
pause >nul
goto CommonToolsMenu

:SpecialToolsMenu
cls
echo ==========================================
echo 特殊工具
echo ==========================================
echo [1] 以管理员权限启动程序 [需管理员]
echo [B] 返回主菜单
echo ==========================================
choice /C 1B /N /M "请输入选项："
if errorlevel 2 goto gotAdmin
if errorlevel 1 goto RunAsAdmin

:RunAsAdmin
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto SpecialToolsMenu )
cls
echo ==========================================
echo 以管理员权限启动程序
echo ==========================================
set /p "runApp=请输入要启动的程序名称或完整路径(如 notepad 或 D:\test.exe)："
if "!runApp!"=="" goto SpecialToolsMenu
set "runApp=!runApp:"=%!"
set "runApp=!runApp:!=!"
choice /C YN /N /M "确认以管理员权限启动 "!runApp!"？[Y/N]"
if errorlevel 2 goto SpecialToolsMenu
echo 正在请求UAC提权并启动...
powershell -Command "Start-Process -FilePath \"!runApp!\" -Verb RunAs" >nul 2>&1
if !errorlevel! equ 0 (
    echo 已发送提权启动请求，请留意弹出的UAC确认框。
) else (
    echo 启动失败，请检查输入的路径是否正确，或程序是否存在。
)
goto SpecialToolsReturn

:SpecialToolsReturn
echo.
echo 按任意键返回特殊工具...
pause >nul
goto SpecialToolsMenu

:: 静默子程序 (全部添加 exit /b)
:ForgetWiFi_NoPrompt
for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces 2^>nul ^| findstr "SSID" ^| findstr /v "BSSID"') do set "SSID=%%a" & goto :ForgetA_NoPrompt
exit /b

:ForgetA_NoPrompt
set "SSID=!SSID: =!"
if "!SSID!"=="" exit /b
netsh wlan disconnect >nul 2>&1
netsh wlan delete profile name="!SSID!" >nul 2>&1
for /f "delims=" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" 2^>nul') do (
    reg query "%%i" /v ProfileName 2>nul | findstr /i "!SSID!" >nul && reg delete "%%i" /f >nul 2>&1
)
exit /b

:RenewIP_NoPrompt
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
exit /b

:FlushDNS_NoPrompt
ipconfig /flushdns >nul 2>&1
net stop dnscache /y >nul 2>&1
net start dnscache >nul 2>&1
exit /b

:ResetWinsock_NoPrompt
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
netsh interface teredo set state disabled >nul 2>&1
exit /b

:ClearSSL_NoPrompt
certutil -urlcache * delete >nul 2>&1
exit /b

:ResetProxy_NoPrompt
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >nul 2>&1
netsh winhttp reset proxy >nul 2>&1
exit /b

:ResetNetworkSharing_NoPrompt
regsvr32 /s netshell.dll
regsvr32 /s netcfgx.dll
regsvr32 /s netman.dll
net stop LanmanServer /y >nul 2>&1
sc config LanmanServer start= auto >nul 2>&1
net start LanmanServer >nul 2>&1
netsh advfirewall firewall set rule group="文件和打印机共享" new enable=Yes >nul 2>&1
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul 2>&1
net share IPC$ >nul 2>&1
exit /b

:ShowIP_NoPrompt
ipconfig /all
exit /b

:PingGateway_NoPrompt
set "GW="
for /f "tokens=2 delims=:" %%g in ('ipconfig ^| findstr /i "网关 Gateway"') do (
    set "GW=%%g"
    if defined GW goto :DoPingGW_NoPrompt
)
:DoPingGW_NoPrompt
set "GW=!GW: =!"
if "!GW!"=="" (
    echo 未找到默认网关。
) else (
    ping -n 4 !GW!
)
exit /b

:TestDNS_NoPrompt
nslookup baidu.com
exit /b

:TestPort_NoPrompt
curl -s -o nul --connect-timeout 3 https://www.baidu.com >nul 2>&1
if errorlevel 1 (echo 端口 443 连接失败。) else (echo 端口 443 连通正常。)
exit /b

:PingSites_NoPrompt
ping -n 4 baidu.com
exit /b

:: 以下为交互功能模块（略作优化，保持原有逻辑）
:CreateRestorePoint
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 创建系统还原点
echo ==========================================
choice /C YN /N /M "创建过程可能需要几分钟，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 正在创建系统还原点，请稍候...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description '网络修复前' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
if !errorlevel! equ 0 (echo 系统还原点创建成功。) else (echo 创建失败，请确认系统保护已开启。)
goto NetworkMenuReturn

:BackupReg
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 备份网络注册表
echo ==========================================
choice /C YN /N /M "将在D盘(或C盘)生成备份文件，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
if exist D:\ (set "BAK_DIR=D:\NetRegBackup") else (set "BAK_DIR=C:\NetRegBackup")
if not exist "!BAK_DIR!" mkdir "!BAK_DIR!" >nul 2>&1
for /f "delims=" %%t in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set "TIME_FILENAME=%%t"
echo 正在备份 NetworkList...
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList" "!BAK_DIR!\NetworkList_!TIME_FILENAME!.reg" /y >nul 2>&1
echo 正在备份 TcpipParams...
reg export "HKLM\SYSTEM\CurrentControlSet\Services\tcpip\Parameters" "!BAK_DIR!\TcpipParams_!TIME_FILENAME!.reg" /y >nul 2>&1
echo 正在备份 WinSock2...
reg export "HKLM\SYSTEM\CurrentControlSet\Services\WinSock2" "!BAK_DIR!\WinSock2_!TIME_FILENAME!.reg" /y >nul 2>&1
echo 网络注册表备份完成，保存至 !BAK_DIR!
goto NetworkMenuReturn

:RestoreReg
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 恢复网络注册表
echo ==========================================
if exist D:\ (set "BAK_DIR=D:\NetRegBackup") else (set "BAK_DIR=C:\NetRegBackup")
if not exist "!BAK_DIR!" (echo 未找到备份目录。 & goto NetworkMenuReturn)
choice /C YN /N /M "恢复注册表可能影响网络设置，确认导入最新备份？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
set "restored=0"
for /f "delims=" %%a in ('dir /b /o-d "!BAK_DIR!\NetworkList_*.reg" 2^>nul') do (
    reg import "!BAK_DIR!\%%a" >nul 2>&1
    if !errorlevel! equ 0 (echo NetworkList 恢复成功 & set /a restored+=1)
    goto :RestoreNext1
)
:RestoreNext1
for /f "delims=" %%a in ('dir /b /o-d "!BAK_DIR!\TcpipParams_*.reg" 2^>nul') do (
    reg import "!BAK_DIR!\%%a" >nul 2>&1
    if !errorlevel! equ 0 (echo TcpipParams 恢复成功 & set /a restored+=1)
    goto :RestoreNext2
)
:RestoreNext2
for /f "delims=" %%a in ('dir /b /o-d "!BAK_DIR!\WinSock2_*.reg" 2^>nul') do (
    reg import "!BAK_DIR!\%%a" >nul 2>&1
    if !errorlevel! equ 0 (echo WinSock2 恢复成功 & set /a restored+=1)
    goto RestoreDone
)
:RestoreDone
if !restored! gtr 0 (echo 注册表恢复完成，建议重启。) else (echo 恢复失败，请检查备份文件。)
goto NetworkMenuReturn

:QuickReconnect
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 快速断网重连（当前物理网卡）
echo ==========================================
echo 正在查找活动物理网卡...
set "adapter="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Virtual -eq $false } | Select-Object -First 1 -ExpandProperty Name"`) do (
    set "adapter=%%a"
    goto :DoReconnect
)
echo 未找到活动网络连接。
goto NetworkMenuReturn

:DoReconnect
echo 当前适配器: !adapter!
choice /C YN /N /M "将禁用并重新启用[!adapter!]，会短暂断网，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
netsh interface set interface "!adapter!" admin=disabled >nul 2>&1
timeout /t 1 /nobreak >nul
netsh interface set interface "!adapter!" admin=enabled >nul 2>&1
echo 网络已重启。
goto NetworkMenuReturn

:ForgetWiFi
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 忘记当前Wi-Fi并清理注册表残留
echo ==========================================
echo 正在获取当前 Wi-Fi...
set "SSID="
for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces 2^>nul ^| findstr "SSID" ^| findstr /v "BSSID"') do set "SSID=%%a"
set "SSID=!SSID: =!"
if "!SSID!"=="" (echo 未连接 Wi-Fi。 & goto NetworkMenuReturn)
echo 当前 Wi-Fi: [!SSID!]
choice /C YN /N /M "将断开[!SSID!]并删除其配置及注册表，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
netsh wlan disconnect >nul 2>&1
netsh wlan delete profile name="!SSID!" >nul 2>&1
echo 正在清理注册表残留...
set "found=0"
for /f "delims=" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles" 2^>nul') do (
    reg query "%%i" /v ProfileName 2>nul | findstr /i "!SSID!" >nul && (
        reg delete "%%i" /f >nul 2>&1 & set /a found+=1
    )
)
if !found! gtr 0 (echo 清理了 !found! 个注册表项。) else (echo 未找到相关注册表项。)
echo 已完成，请重新连接。
goto NetworkMenuReturn

:RenewIP
cls
echo ==========================================
echo 释放并更新IP地址
echo ==========================================
choice /C YN /N /M "将释放当前IP并重新获取，会导致短暂断网，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 释放IP地址...
ipconfig /release
echo 获取新IP地址...
ipconfig /renew
echo IP地址已更新。
goto NetworkMenuReturn

:FlushDNS
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 刷新DNS缓存并重启DNS服务
echo ==========================================
choice /C YN /N /M "将清空DNS缓存并重启DNS Client服务，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 刷新DNS缓存...
ipconfig /flushdns
echo 重启DNS客户端服务...
net stop dnscache /y >nul 2>&1
net start dnscache >nul 2>&1
echo DNS缓存已刷新。
goto NetworkMenuReturn

:ResetWinsock
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 重置Winsock与IP协议栈
echo ==========================================
choice /C YN /N /M "重置后必须重启电脑才能生效，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 重置Winsock...
netsh winsock reset
echo 重置IP协议栈...
netsh int ip reset
echo 禁用Teredo...
netsh interface teredo set state disabled
echo 重置完成，请重启电脑。
goto NetworkMenuReturn

:ClearSSL
cls
echo ==========================================
echo 清除SSL证书缓存
echo ==========================================
choice /C YN /N /M "将清空系统的SSL状态和缓存，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 清除SSL证书缓存...
certutil -urlcache * delete >nul 2>&1
echo SSL缓存已清空。
goto NetworkMenuReturn

:ClearARP
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 清除ARP缓存
echo ==========================================
choice /C YN /N /M "将清空系统的ARP缓存表，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 正在清除ARP缓存...
netsh interface ip delete arpcache >nul 2>&1
arp -d * >nul 2>&1
echo ARP缓存已清空。
goto NetworkMenuReturn

:RepairTCP
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo TCP连接修复
echo ==========================================
echo 此操作将重置TCP全局参数(如自动调谐级别)，修复部分连接被重置问题。
choice /C YN /N /M "确认执行TCP参数重置？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 正在重置TCP参数...
netsh int tcp reset >nul 2>&1
echo TCP参数已重置完成。建议重启电脑。
goto NetworkMenuReturn

:ChangeMAC
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 修改无线网卡 MAC 地址
echo ==========================================
echo 正在查找无线网卡...
set "WLAN_ADAPTER="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.MediaType -eq 'Native 802.11' } | Select-Object -First 1 -ExpandProperty Name"`) do (
    set "WLAN_ADAPTER=%%a"
    goto :FoundAdapterMAC
)
echo 未找到无线网卡。
goto NetworkMenuReturn

:FoundAdapterMAC
echo 无线网卡: !WLAN_ADAPTER!
set "MAC=02A1B2C3D4E5"
choice /C YN /N /M "将[!WLAN_ADAPTER!]的MAC修改为!MAC!，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
set "REGKEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
set "modified=0"
for /f "tokens=*" %%i in ('reg query "!REGKEY!" /s /f "!WLAN_ADAPTER!" /d 2^>nul ^| findstr "HKEY"') do (
    reg add "%%i" /v NetworkAddress /t REG_SZ /d !MAC! /f >nul 2>&1
    if !errorlevel! equ 0 (set /a modified+=1)
)
if !modified! gtr 0 (echo 修改成功。) else (echo 修改失败，网卡不支持。)
echo 操作完成，重连Wi-Fi生效。
goto NetworkMenuReturn

:RestoreMAC
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 恢复原始 MAC 地址
echo ==========================================
echo 正在查找无线网卡...
set "WLAN_ADAPTER="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.MediaType -eq 'Native 802.11' } | Select-Object -First 1 -ExpandProperty Name"`) do (
    set "WLAN_ADAPTER=%%a"
    goto :RestoreAdapter
)
echo 未找到无线网卡。
goto NetworkMenuReturn

:RestoreAdapter
echo 无线网卡: !WLAN_ADAPTER!
choice /C YN /N /M "将清除[!WLAN_ADAPTER!]的自定义MAC，重启后恢复，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
set "REGKEY=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
set "deleted=0"
for /f "tokens=*" %%i in ('reg query "!REGKEY!" /s /f "!WLAN_ADAPTER!" /d 2^>nul ^| findstr "HKEY"') do (
    reg query "%%i" /v NetworkAddress >nul 2>&1 && (
        reg delete "%%i" /v NetworkAddress /f >nul 2>&1 & set /a deleted+=1
    )
)
echo 已清除自定义MAC，重启电脑恢复原生地址。
goto NetworkMenuReturn

:RebootPC
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 重启电脑
echo ==========================================
choice /C YN /T 5 /D N /M "系统将立即重启并丢失未保存的数据，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 正在重启电脑...
shutdown /r /t 0
goto End

:NetMon360
cls
echo ==========================================
echo 360断网急救箱
echo ==========================================
echo 需提前安装 360 安全卫士（断网急救箱随附其中）。
set "netmonExe="
if exist "%~dp0360NetRepair.exe" set "netmonExe=%~dp0360NetRepair.exe"
if not defined netmonExe if exist "C:\Program Files (x86)\360\360Safe\netmon\360NetRepair.exe" set "netmonExe=C:\Program Files (x86)\360\360Safe\netmon\360NetRepair.exe"
if not defined netmonExe if exist "C:\Program Files\360\360Safe\netmon\360NetRepair.exe" set "netmonExe=C:\Program Files\360\360Safe\netmon\360NetRepair.exe"
if not defined netmonExe if exist "%ProgramData%\360Safe\netmon\360NetRepair.exe" set "netmonExe=%ProgramData%\360Safe\netmon\360NetRepair.exe"
if defined netmonExe (
    echo 检测到本地断网急救箱："%netmonExe%"
    choice /C YN /N /M "将尝试调用外部360程序，确认启动？[Y/N]"
    if errorlevel 2 goto NetworkMenu
    start "" "%netmonExe%"
    echo 已启动360断网急救箱
    goto NetworkMenuReturn
)
echo 本地未找到 360 断网急救箱。
echo.
echo 获取方式（均为 360 官方渠道）：
echo [1] 下载 360 安全卫士官方安装包（断网急救箱随附其中）
echo [2] 打开 360 官方「断网急救箱」介绍页
echo [B] 返回网络修复菜单
echo.
choice /C 12B /N /M "请选择："
if errorlevel 3 goto NetworkMenu
if errorlevel 2 goto Open360NetRepairPage
if errorlevel 1 goto Download360Safe

:Open360NetRepairPage
echo.
echo 正在打开 360 官方「断网急救箱」介绍页...
start "" "https://weishi.360.cn/work/dwjjx/"
goto NetworkMenuReturn

:LSPFix360
cls
echo ==========================================
echo 360 LSP修复工具
echo ==========================================
echo 需提前安装360安全卫士
set "lspExe="
if exist "C:\Program Files (x86)\360\360Safe\Utils\LSPFix.exe" set "lspExe=C:\Program Files (x86)\360\360Safe\Utils\LSPFix.exe"
if exist "C:\Program Files\360\360Safe\Utils\LSPFix.exe" set "lspExe=C:\Program Files\360\360Safe\Utils\LSPFix.exe"
if exist "%ProgramData%\360Safe\Utils\LSPFix.exe" set "lspExe=%ProgramData%\360Safe\Utils\LSPFix.exe"
if not defined lspExe (echo 未找到360 LSP修复工具！ & echo 按任意键返回网络修复菜单... & pause >nul & goto NetworkMenu)
choice /C YN /N /M "将尝试调用外部LSP修复程序，确认启动？[Y/N]"
if errorlevel 2 goto NetworkMenu
start "" "!lspExe!"
echo 已启动360 LSP修复工具
goto NetworkMenuReturn

:AllInOne
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 一键全面修复
echo ==========================================
echo 执行：WiFi清理/重置IP/DNS/协议栈/SSL/代理/共享
echo 注意：此操作耗时较长，且会中断当前网络连接。
choice /C YN /N /M "将一键执行多项网络重置操作，完成后必须重启电脑，确认执行？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo [1/7] 清理Wi-Fi...
call :ForgetWiFi_NoPrompt
echo [2/7] 更新IP...
call :RenewIP_NoPrompt
echo [3/7] 刷新DNS...
call :FlushDNS_NoPrompt
echo [4/7] 重置网络协议栈...
call :ResetWinsock_NoPrompt
echo [5/7] 清除SSL缓存...
call :ClearSSL_NoPrompt
echo [6/7] 重置代理服务器...
call :ResetProxy_NoPrompt
echo [7/7] 重置网络共享设置...
call :ResetNetworkSharing_NoPrompt
echo.
echo ==========================================
echo 一键修复完成！
echo 强烈建议立即重启电脑以使所有重置生效。
echo ==========================================
goto NetworkMenuReturn

:NetworkCheck
cls
echo ==========================================
echo 网络检测工具
echo ==========================================
echo [1] 查看IP详情
echo [2] 测试网关连通性
echo [3] DNS解析测试
echo [4] 端口连通性测试
echo [5] 网站连通性测试
echo [6] 一键全面检测
echo [B] 返回网络修复菜单
echo ==========================================
choice /C 123456B /N /M "请选择检测项目："
if errorlevel 7 goto NetworkMenu
if errorlevel 6 goto OneClickNetworkCheck
if errorlevel 5 goto PingSites
if errorlevel 4 goto TestPort
if errorlevel 3 goto TestDNS
if errorlevel 2 goto PingGateway
if errorlevel 1 goto ShowIP

:OneClickNetworkCheck
cls
echo ==========================================
echo 一键全面检测
echo ==========================================
echo 正在执行网络检测，请稍候，这可能需要一点时间...
echo.
echo [1/5] 查看IP详情...
call :ShowIP_NoPrompt
echo.
echo [2/5] 测试网关连通性...
call :PingGateway_NoPrompt
echo.
echo [3/5] DNS解析测试(默认: baidu.com)...
call :TestDNS_NoPrompt
echo.
echo [4/5] 端口连通性测试(默认: baidu.com:443)...
call :TestPort_NoPrompt
echo.
echo [5/5] 网站连通性测试(默认: baidu.com)...
call :PingSites_NoPrompt
echo.
echo ==========================================
echo 一键检测完成！
echo ==========================================
pause
goto NetworkCheck

:ShowIP
choice /C YN /N /M "将调用ipconfig显示所有网络适配器详细信息，确认执行？[Y/N]"
if errorlevel 2 goto NetworkCheck
call :ShowIP_NoPrompt
echo.
echo 按任意键返回网络检测菜单...
pause >nul
goto NetworkCheck

:PingGateway
choice /C YN /N /M "将向默认网关发送4个测试包，确认执行？[Y/N]"
if errorlevel 2 goto NetworkCheck
call :PingGateway_NoPrompt
echo.
echo 按任意键返回网络检测菜单...
pause >nul
goto NetworkCheck

:TestDNS
cls
echo ==========================================
echo DNS解析测试
echo ==========================================
echo [1] 百度 [2] 淘宝 [3] 腾讯
echo [4] 自定义网址(使用默认DNS)
echo [5] 指定DNS服务器解析
echo [B] 返回
echo ==========================================
choice /C 12345B /N /M "请选择："
if errorlevel 6 goto NetworkCheck
if errorlevel 5 goto CustomDNSTest
if errorlevel 4 goto CustomURLDefaultDNS
if errorlevel 3 set "testURL=qq.com" & goto DoDNSDefault
if errorlevel 2 set "testURL=taobao.com" & goto DoDNSDefault
if errorlevel 1 set "testURL=baidu.com" & goto DoDNSDefault

:DoDNSDefault
echo.
echo 正在使用默认DNS解析 [!testURL!] ...
nslookup !testURL!
echo.
echo 按任意键返回DNS解析测试...
pause >nul
goto TestDNS

:CustomURLDefaultDNS
set "testURL="
set /p "testURL=请输入要解析的网址(如 example.com)："
if "!testURL!"=="" goto TestDNS
set "testURL=!testURL:"=%!"
set "testURL=!testURL:!=!"
echo.
echo 正在使用默认DNS解析 [!testURL!] ...
nslookup !testURL!
echo.
echo 按任意键返回DNS解析测试...
pause >nul
goto TestDNS

:CustomDNSTest
cls
echo ==========================================
echo 选择DNS服务器
echo ==========================================
echo [1] 阿里DNS (223.5.5.5)
echo [2] 腾讯DNS (119.29.29.29)
echo [3] 114DNS (114.114.114.114)
echo [4] 谷歌DNS (8.8.8.8)
echo [5] 自定义DNS服务器
echo [B] 返回
echo ==========================================
choice /C 12345B /N /M "请选择DNS："
if errorlevel 6 goto TestDNS
if errorlevel 5 goto InputCustomDNS
if errorlevel 4 set "testDNS=8.8.8.8" & goto SelectURLForDNS
if errorlevel 3 set "testDNS=114.114.114.114" & goto SelectURLForDNS
if errorlevel 2 set "testDNS=119.29.29.29" & goto SelectURLForDNS
if errorlevel 1 set "testDNS=223.5.5.5" & goto SelectURLForDNS

:InputCustomDNS
set "testDNS="
set /p "testDNS=请输入DNS服务器IP："
if "!testDNS!"=="" goto CustomDNSTest
set "testDNS=!testDNS:"=%!"

:SelectURLForDNS
cls
echo ==========================================
echo 选择解析网址
echo ==========================================
echo [1] 百度 [2] 淘宝 [3] 腾讯
echo [4] 自定义网址
echo ==========================================
choice /C 1234 /N /M "请选择："
if errorlevel 4 goto InputCustomURL
if errorlevel 3 set "testURL=qq.com" & goto DoDNSCustom
if errorlevel 2 set "testURL=taobao.com" & goto DoDNSCustom
if errorlevel 1 set "testURL=baidu.com" & goto DoDNSCustom

:InputCustomURL
set "testURL="
set /p "testURL=请输入要解析的网址："
if "!testURL!"=="" goto SelectURLForDNS
set "testURL=!testURL:"=%!"

:DoDNSCustom
echo.
echo 正在使用 [!testDNS!] 解析 [!testURL!] ...
nslookup !testURL! !testDNS!
echo.
echo 按任意键返回DNS解析测试...
pause >nul
goto TestDNS

:TestPort
choice /C YN /N /M "将测试百度的443端口(HTTPS)连通性，确认执行？[Y/N]"
if errorlevel 2 goto NetworkCheck
call :TestPort_NoPrompt
echo.
echo 按任意键返回网络检测菜单...
pause >nul
goto NetworkCheck

:PingSites
cls
echo ==========================================
echo 网站连通性
echo ==========================================
echo [1] 百度 [2] 淘宝 [3] 腾讯
echo [4] 自定义网址
echo [B] 返回
echo ==========================================
choice /C 1234B /N /M "请选择："
if errorlevel 5 goto NetworkCheck
if errorlevel 4 goto CustomPing
if errorlevel 3 set "pingURL=qq.com" & goto DoPing
if errorlevel 2 set "pingURL=taobao.com" & goto DoPing
if errorlevel 1 set "pingURL=baidu.com" & goto DoPing

:CustomPing
set "pingURL="
set /p "pingURL=请输入要Ping的网址或IP："
if "!pingURL!"=="" goto PingSites
set "pingURL=!pingURL:"=%!"

:DoPing
echo.
echo 正在Ping [!pingURL!] ...
ping -n 4 !pingURL!
echo.
echo 按任意键返回网站连通性测试...
pause >nul
goto PingSites

:AdvancedMenu
cls
echo ==========================================
echo 高级网络工具
echo ==========================================
echo [1] 强制重置无线网卡 [需管理员]
echo [2] 删除虚拟适配器 [需管理员]
echo [3] 深度清理Wi-Fi配置 [需管理员]
echo [B] 返回网络菜单
echo ==========================================
choice /C 123B /N /M "请输入选项："
if errorlevel 4 goto NetworkMenu
if errorlevel 3 goto ClearProfile
if errorlevel 2 goto RemoveVirtual
if errorlevel 1 goto ForceResetWLAN

:ForceResetWLAN
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto AdvancedReturn )
cls
echo ==========================================
echo 强制重置无线网卡
echo ==========================================
choice /C YN /N /M "将强制关闭并重启无线网卡驱动，确认执行？[Y/N]"
if errorlevel 2 goto AdvancedReturn
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.MediaType -eq 'Native 802.11' } | Select-Object -First 1 -ExpandProperty Name"`) do (
    netsh interface set interface "%%a" admin=disabled >nul 2>&1
    timeout /t 2 /nobreak >nul
    netsh interface set interface "%%a" admin=enabled >nul 2>&1
)
echo 无线网卡强制重置完成
goto AdvancedReturn

:RemoveVirtual
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto AdvancedReturn )
cls
echo ==========================================
echo 删除虚拟适配器
echo ==========================================
choice /C YN /N /M "将通过注册表禁用Microsoft虚拟WIFI网卡，确认执行？[Y/N]"
if errorlevel 2 goto AdvancedReturn
powershell -NoProfile -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\vwifimp' -Name 'Start' -Value 4 -Force" >nul 2>&1
echo 虚拟网卡清理完成
goto AdvancedReturn

:ClearProfile
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto AdvancedReturn )
cls
echo ==========================================
echo 深度清理Wi-Fi配置
echo ==========================================
set "SSID="
for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces 2^>nul ^| findstr "SSID" ^| findstr /v "BSSID"') do set "SSID=%%a"
set "SSID=!SSID: =!"
if "!SSID!"=="" (echo 无Wi-Fi连接 & echo 按任意键返回高级网络工具... & pause >nul & goto AdvancedReturn)
echo 当前Wi-Fi: [!SSID!]
choice /C YN /N /M "将删除[!SSID!]的配置文件(不清理注册表)，确认执行？[Y/N]"
if errorlevel 2 goto AdvancedReturn
netsh wlan delete profile name="!SSID!" >nul 2>&1
echo Wi-Fi配置文件深度清理完成
goto AdvancedReturn

:FirewallMenu
cls
echo ========================================
echo 防火墙状态查看
echo ========================================
echo.
echo [01] 防火墙深度诊断
echo [02] 检查出站规则
echo [03] 检查入站规则
echo [00] 返回网络菜单
echo.
set "fwChoice="
set /p "fwChoice=请选择操作 (00-03): "
set "fwChoice=!fwChoice: =!"
if "!fwChoice!"=="01" goto FirewallDiagnosis
if "!fwChoice!"=="02" goto CheckOutboundRules
if "!fwChoice!"=="03" goto CheckInboundRules
if "!fwChoice!"=="00" goto NetworkMenu
echo 无效选择！请重新输入。
timeout /t 2 /nobreak >nul
goto FirewallMenu

:FirewallDiagnosis
cls
echo ========================================
echo 防火墙深度诊断脚本
echo ========================================
set "FD=%TEMP%\FirewallDiag"
if not exist "%FD%" mkdir "%FD%"
echo.
echo [1/8] 检查默认出站策略...
netsh advfirewall show allprofiles | findstr "防火墙策略" > "%FD%\default_policy.txt"
echo 默认策略已保存到 "%FD%\default_policy.txt"
echo.
echo [2/8] 检查入站规则...
netsh advfirewall firewall show rule name=all dir=in > "%FD%\inbound_rules.txt"
echo 入站规则已保存到 "%FD%\inbound_rules.txt"
echo.
echo [3/8] 检查连接安全规则...
netsh advfirewall consec show rule name=all > "%FD%\consec_rules.txt"
echo 连接安全规则已保存到 "%FD%\consec_rules.txt"
echo.
echo [4/8] 检查UU Accelerator服务...
sc query | findstr /i "uu" > "%FD%\uu_services.txt"
echo UU服务信息已保存到 "%FD%\uu_services.txt"
echo.
echo [5/8] 检查网络驱动...
driverquery | findstr /i "uu" > "%FD%\uu_drivers.txt"
echo UU驱动信息已保存到 "%FD%\uu_drivers.txt"
echo.
echo [6/8] 检查所有规则（详细）...
netsh advfirewall firewall show rule name=all verbose > "%FD%\all_rules_verbose.txt"
echo 详细规则已保存到 "%FD%\all_rules_verbose.txt"
echo.
echo [7/8] 检查是否有阻止规则...
findstr "阻止" "%FD%\all_rules_verbose.txt" > "%FD%\blocking_rules.txt"
echo 阻止规则已保存到 "%FD%\blocking_rules.txt"
echo.
echo [8/8] 生成诊断报告...
echo ======================================== > "%FD%\firewall_deep_diagnosis.txt"
echo 防火墙深度诊断报告 >> "%FD%\firewall_deep_diagnosis.txt"
echo 生成时间：%date% %time% >> "%FD%\firewall_deep_diagnosis.txt"
echo ======================================== >> "%FD%\firewall_deep_diagnosis.txt"
echo. >> "%FD%\firewall_deep_diagnosis.txt"
type "%FD%\default_policy.txt" >> "%FD%\firewall_deep_diagnosis.txt"
echo. >> "%FD%\firewall_deep_diagnosis.txt"
echo --- 阻止规则数量 --- >> "%FD%\firewall_deep_diagnosis.txt"
find /c "阻止" "%FD%\blocking_rules.txt" >> "%FD%\firewall_deep_diagnosis.txt"
echo. >> "%FD%\firewall_deep_diagnosis.txt"
echo --- UU Accelerator服务 --- >> "%FD%\firewall_deep_diagnosis.txt"
type "%FD%\uu_services.txt" >> "%FD%\firewall_deep_diagnosis.txt"
echo.
echo ========================================
echo 诊断完成！
echo 请查看报告: "%FD%\firewall_deep_diagnosis.txt"
echo ========================================
start notepad "%FD%\firewall_deep_diagnosis.txt"
pause
goto FirewallMenu

:CheckOutboundRules
cls
echo ========================================
echo 检查防火墙出站规则
echo ========================================
echo.
set "FD=%TEMP%\FirewallDiag"
if not exist "%FD%" mkdir "%FD%"
netsh advfirewall firewall show rule name=all dir=out > "%FD%\outbound_rules.txt"
echo 出站规则已保存到 "%FD%\outbound_rules.txt"
echo.
type "%FD%\outbound_rules.txt" | more
echo.
echo 出站规则检查完成！
pause
goto FirewallMenu

:CheckInboundRules
cls
echo ========================================
echo 检查防火墙入站规则
echo ========================================
echo.
set "FD=%TEMP%\FirewallDiag"
if not exist "%FD%" mkdir "%FD%"
netsh advfirewall firewall show rule name=all dir=in > "%FD%\inbound_rules.txt"
echo 入站规则已保存到 "%FD%\inbound_rules.txt"
echo.
type "%FD%\inbound_rules.txt" | more
echo.
echo 入站规则检查完成！
pause
goto FirewallMenu

:AdvancedReturn
echo.
echo 按任意键返回高级网络工具...
pause >nul
goto AdvancedMenu

:NetworkMenuReturn
echo.
echo 按任意键返回网络修复菜单...
pause >nul
goto NetworkMenu

:ResetProxy
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 重置代理服务器设置
echo ==========================================
echo 此操作将关闭系统代理并清除相关配置。
echo 包括：关闭代理开关、清除代理服务器地址、清除自动配置脚本(PAC)、重置底层WinHTTP代理。
echo.
choice /C YN /N /M "确认重置所有代理设置？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 正在重置代理服务器设置...
call :ResetProxy_NoPrompt
echo 代理服务器设置已彻底重置完成。
echo 提示：如果浏览器仍有缓存代理，建议重启浏览器或重启电脑以完全生效。
goto NetworkMenuReturn

:ResetNetworkSharing
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 重置网络共享设置
echo ==========================================
echo 此操作将修复文件和打印机共享功能，包括：
echo 1. 重新注册共享相关核心组件 (DLL)
echo 2. 重启并自启 Server 服务
echo 3. 重置防火墙的文件和打印机共享规则
echo 4. 清除共享缓存并重建默认共享 (IPC$)
echo.
choice /C YN /N /M "确认重置网络共享设置？[Y/N]"
if errorlevel 2 goto NetworkMenuReturn
echo 正在重置网络共享设置...
call :ResetNetworkSharing_NoPrompt
echo 网络共享设置重置完成！
echo 提示：如果仍然无法访问共享，建议重启电脑以确保所有底层服务刷新生效。
goto NetworkMenuReturn

:SetMTU
if "!isAdmin!"=="0" ( echo 普通模式下无权限执行此操作。 & timeout /t 2 /nobreak >nul & goto NetworkMenuReturn )
cls
echo ==========================================
echo 设置网络接口的 MTU 值
echo ==========================================
echo 当前可用网络接口列表：
echo.
netsh interface ipv4 show subinterfaces
echo.
echo ------------------------------------------
set /p "ifname=请输入要修改的接口名称（例如：WLAN、以太网）："
if "!ifname!"=="" (
    echo 接口名称不能为空！按任意键返回...
    pause >nul
    goto NetworkMenu
)
set /p "mtuval=请输入新的 MTU 值（推荐 1400-1500，最大 1500）："
if "!mtuval!"=="" (
    echo MTU值不能为空！按任意键返回...
    pause >nul
    goto NetworkMenu
)
echo !mtuval!|findstr /r "^[0-9]*$" >nul
if errorlevel 1 (
    echo 错误：MTU值必须为纯数字！按任意键返回...
    pause >nul
    goto NetworkMenu
)
echo.
echo 正在设置接口 "!ifname!" 的 MTU = !mtuval! ...
netsh interface ipv4 set subinterface "!ifname!" mtu=!mtuval! store=persistent
if errorlevel 1 (
    echo 设置失败！请确认：
    echo   - 接口名称是否正确（区分大小写，参考上面列表）
    echo   - 是否以管理员身份运行
    echo   - MTU 值是否在有效范围内（通常 576-1500）
) else (
    echo 设置成功！
)
echo.
echo 按任意键返回菜单...
pause >nul
goto NetworkMenu

:: ============================================================
:: 网络问题扫描与修复 v0.6.0 新增
:: ============================================================
:NetworkScan
if "!isAdmin!"=="0" (
    echo [提示] 当前为普通模式，部分扫描项与全部修复项需要管理员权限。
    echo 建议重新启动工具箱并选择 [管理员模式] 以获得完整修复能力。
    echo.
)
echo ==========================================
echo 开始扫描所有可能的网络问题...
echo ==========================================
set "scan_issue_count=0"
echo.
call :Scan_Adapter
call :Scan_IPv4
call :Scan_Gateway
call :Scan_Internet
call :Scan_DNS
call :Scan_DNSServer
call :Scan_Proxy
call :Scan_Hosts
call :Scan_DHCP
call :Scan_DNSClient
call :Scan_Firewall
call :Scan_Port443
call :Scan_MTU
echo.
echo ==========================================
echo 扫描完成！
echo ==========================================
if !scan_issue_count! equ 0 (
    echo.
    echo 未发现网络问题，一切正常。
    echo.
    echo 按任意键返回网络修复菜单...
    pause >nul
    goto NetworkMenu
)
echo.
echo 发现 !scan_issue_count! 个潜在问题：
echo.
for /l %%i in (1,1,!scan_issue_count!) do (
    echo [%%i] !scan_issue[%%i]!
    if "!scan_fix[%%i]!"=="none" (
        echo      手动修复: !scan_manual[%%i]!
    )
)
echo.
echo 修复选项：
echo [1] 一键修复全部可修复项
echo [2] 仅查看，不修复
echo [B] 返回网络菜单
echo ==========================================
choice /C 12B /N /M "请选择："
if errorlevel 3 goto NetworkMenu
if errorlevel 2 goto NetworkMenu
if errorlevel 1 goto ScanFixAll

:ScanFixAll
echo.
choice /C YN /N /M "确认执行修复？部分修复需管理员权限 [Y/N]"
if errorlevel 2 goto NetworkMenu
echo.
if "!isAdmin!"=="0" (
    echo 当前普通模式无法执行修复，请重新以管理员模式启动。
    echo 按任意键返回网络修复菜单...
    pause >nul
    goto NetworkMenu
)
echo 正在执行修复...
echo.
for /l %%i in (1,1,!scan_issue_count!) do (
    call :DoFix "%%i"
)
echo.
echo ==========================================
echo 修复操作已完成！
echo 部分修复(Winsock/TCP/IP/DNS)需重启电脑完全生效。
echo ==========================================
echo 按任意键返回网络修复菜单...
pause >nul
goto NetworkMenu

:DoFix
set "fix_idx=%~1"
set "fix_type=!scan_fix[%fix_idx%]!"
if "!fix_type!"=="none" (
    echo [%fix_idx%] !scan_issue[%fix_idx%]! -- 无法自动修复
    call echo      手动修复: %%scan_manual[%fix_idx%]%%
    exit /b
)
if "!fix_type!"=="renew" (
    echo [%fix_idx%] 释放并重新获取 IP...
    ipconfig /release >nul 2>&1
    ipconfig /renew >nul 2>&1
    echo      完成。
    exit /b
)
if "!fix_type!"=="netreset" (
    echo [%fix_idx%] 重置网络协议栈 Winsock/TCP/IP...
    netsh winsock reset >nul 2>&1
    netsh int ip reset >nul 2>&1
    netsh winhttp reset proxy >nul 2>&1
    echo      完成，重启后生效。
    exit /b
)
if "!fix_type!"=="dnsfix" (
    echo [%fix_idx%] 刷新DNS并设置公共DNS 223.5.5.5...
    ipconfig /flushdns >nul 2>&1
    call :SetDNS_223
    echo      完成。
    exit /b
)
if "!fix_type!"=="proxy" (
    echo [%fix_idx%] 重置代理设置...
    call :ResetProxy_NoPrompt
    echo      完成。
    exit /b
)
if "!fix_type!"=="dhcp" (
    echo [%fix_idx%] 启动 DHCP 客户端服务...
    sc config dhcp start= auto >nul 2>&1
    net start dhcp >nul 2>&1
    echo      完成。
    exit /b
)
if "!fix_type!"=="dnscache" (
    echo [%fix_idx%] 启动 DNS Client 服务...
    sc config dnscache start= auto >nul 2>&1
    net start dnscache >nul 2>&1
    echo      完成。
    exit /b
)
if "!fix_type!"=="firewall" (
    echo [%fix_idx%] 启用 Windows 防火墙...
    netsh advfirewall set allprofiles state on >nul 2>&1
    echo      完成。
    exit /b
)
if "!fix_type!"=="hosts" (
    echo [%fix_idx%] 备份并清理 hosts 疑似劫持条目...
    call :FixHosts
    echo      完成。
    exit /b
)
if "!fix_type!"=="mtu" (
    echo [%fix_idx%] 调整 MTU 为 1400...
    call :SetMTU_1400
    echo      完成。
    exit /b
)
echo [%fix_idx%] 未知修复动作，跳过。
exit /b

:SetDNS_223
set "ADAPTER_N="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1 -ExpandProperty Name"`) do set "ADAPTER_N=%%a"
if "!ADAPTER_N!"=="" (
    echo      未找到活动网卡，跳过DNS设置。
    exit /b
)
netsh interface ip set dns "!ADAPTER_N!" static 223.5.5.5 primary >nul 2>&1
netsh interface ip add dns "!ADAPTER_N!" 119.29.29.29 index=2 >nul 2>&1
echo      已设置 DNS: 223.5.5.5 / 119.29.29.29
exit /b

:FixHosts
set "HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts"
set "HOSTS_BAK=!HOSTS_FILE!.bak_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "HOSTS_BAK=!HOSTS_BAK: =0!"
copy /y "!HOSTS_FILE!" "!HOSTS_BAK!" >nul 2>&1
if errorlevel 1 (
    echo      备份 hosts 失败，已中止修改。
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$h='!HOSTS_FILE!';$new=Get-Content $h | Where-Object { $_ -notmatch '^\s*(0\.0\.0\.0|127\.0\.0\.1)\s+(qq\.com|taobao\.com|baidu\.com|weixin|alipay|360\.cn|360safe|163\.com)' };Set-Content -Path $h -Value $new -Encoding ASCII" >nul 2>&1
if !errorlevel! equ 0 (
    echo      已移除疑似劫持条目，备份位于: !HOSTS_BAK!
    ipconfig /flushdns >nul 2>&1
) else (
    echo      清理失败，请手动检查 hosts 文件。
)
exit /b

:SetMTU_1400
set "ADAPTER_N="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1 -ExpandProperty Name"`) do set "ADAPTER_N=%%a"
if "!ADAPTER_N!"=="" (
    echo      未找到活动网卡，跳过 MTU 设置。
    exit /b
)
netsh interface ipv4 set subinterface "!ADAPTER_N!" mtu=1400 store=persistent >nul 2>&1
if errorlevel 1 (
    echo      MTU 设置失败，请手动设置: netsh interface ipv4 set subinterface "!ADAPTER_N!" mtu=1400 store=persistent
) else (
    echo      已设置网卡 [!ADAPTER_N!] 的 MTU = 1400，需重启或重连网卡生效。
)
exit /b

:: 扫描子程序
:Scan_Adapter
echo [1/13] 检查网络适配器状态...
set "ADAPTER_UP="
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Measure-Object | Select-Object -ExpandProperty Count"`) do set "ADAPTER_UP=%%a"
if "!ADAPTER_UP!"=="" set "ADAPTER_UP=0"
if !ADAPTER_UP! equ 0 (
    call :ScanRecord "网络适配器无已连接状态" "none" "检查网线是否插好/Wi-Fi开关是否打开/飞行模式是否关闭，设备管理器看网卡驱动有无感叹号"
) else (
    echo [通过] 网络适配器已连接
)
exit /b

:Scan_IPv4
echo [2/13] 检查 IPv4 地址...
set "IPV4="
for /f "tokens=2 delims=:" %%a in ('ipconfig 2^>nul ^| findstr /i "IPv4"') do (
    set "IPV4=%%a"
    goto :Scan_IPv4_done
)
:Scan_IPv4_done
set "IPV4=!IPV4: =!"
if "!IPV4!"=="" (
    call :ScanRecord "未获取到 IPv4 地址，DHCP 分配可能失败" "renew"
) else if "!IPV4:~0,7!"=="169.254" (
    call :ScanRecord "IPv4 为 APIPA 地址 !IPV4!，DHCP 分配失败" "renew"
) else (
    echo [通过] IPv4 地址: !IPV4!
)
exit /b

:Scan_Gateway
echo [3/13] 检查默认网关连通性...
set "GW="
for /f "tokens=2 delims=:" %%g in ('ipconfig ^| findstr /i "网关 Gateway"') do (
    set "GW=%%g"
    goto :Scan_Gateway_done
)
:Scan_Gateway_done
set "GW=!GW: =!"
if "!GW!"=="" (
    call :ScanRecord "未检测到默认网关" "none" "检查路由器是否开机、网线是否接路由 LAN 口、本机网卡是否开启，或联系网络管理员"
    exit /b
)
ping -n 2 !GW! >nul 2>&1
if errorlevel 1 (
    call :ScanRecord "默认网关 !GW! ping 不通" "netreset"
) else (
    echo [通过] 默认网关 !GW! 连通正常
)
exit /b

:Scan_Internet
echo [4/13] 检查外网连通性...
ping -n 2 223.5.5.5 >nul 2>&1
if errorlevel 1 (
    call :ScanRecord "外网连通失败，ping 223.5.5.5 不通" "netreset"
) else (
    echo [通过] 外网连通正常
)
exit /b

:Scan_DNS
echo [5/13] 检查 DNS 解析...
nslookup baidu.com 2>nul | findstr /i "非权威 Non-authoritative Name 名称 Addresses" >nul
if errorlevel 1 (
    call :ScanRecord "DNS 解析异常，nslookup baidu.com 失败" "dnsfix"
) else (
    echo [通过] DNS 解析正常
)
exit /b

:Scan_DNSServer
echo [6/13] 检查 DNS 服务器配置...
set "DNSSRV="
for /f "tokens=2 delims=:" %%d in ('ipconfig /all 2^>nul ^| findstr /i "DNS" ^| findstr /i "服务器 Servers"') do (
    set "DNSSRV=%%d"
    goto :Scan_DNSServer_done
)
:Scan_DNSServer_done
set "DNSSRV=!DNSSRV: =!"
if "!DNSSRV!"=="" (
    call :ScanRecord "未配置 DNS 服务器" "dnsfix"
) else (
    echo [通过] DNS 服务器: !DNSSRV!
)
exit /b

:Scan_Proxy
echo [7/13] 检查系统代理设置...
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2>nul | findstr /i "0x1" >nul
if errorlevel 1 (
    echo [通过] 系统代理未开启
) else (
    call :ScanRecord "系统代理已开启，可能导致上网异常" "proxy"
)
exit /b

:Scan_Hosts
echo [8/13] 检查 hosts 文件劫持...
findstr /i /b "0.0.0.0 127.0.0.1" C:\Windows\System32\drivers\etc\hosts 2>nul | findstr /i "qq.com taobao.com baidu.com weixin alipay 360.cn 163.com" >nul
if errorlevel 1 (
    echo [通过] hosts 文件未见常见劫持条目
) else (
    call :ScanRecord "hosts 文件存在疑似劫持条目，注意：若是手动广告屏蔽可忽略" "hosts"
)
exit /b

:Scan_DHCP
echo [9/13] 检查 DHCP 客户端服务...
sc query dhcp 2>nul | findstr /i "RUNNING" >nul
if errorlevel 1 (
    call :ScanRecord "DHCP 客户端服务未运行" "dhcp"
) else (
    echo [通过] DHCP 客户端服务运行中
)
exit /b

:Scan_DNSClient
echo [10/13] 检查 DNS Client 服务...
sc query dnscache 2>nul | findstr /i "RUNNING" >nul
if errorlevel 1 (
    call :ScanRecord "DNS Client 服务未运行" "dnscache"
) else (
    echo [通过] DNS Client 服务运行中
)
exit /b

:Scan_Firewall
echo [11/13] 检查 Windows 防火墙状态...
set "FWSTATE="
for /f "delims=" %%f in ('netsh advfirewall show allprofiles state 2^>nul ^| findstr /i "状态 State"') do set "FWSTATE=%%f"
echo !FWSTATE! | findstr /i "启用 ON 开" >nul
if errorlevel 1 (
    call :ScanRecord "Windows 防火墙未启用，存在安全风险" "firewall"
) else (
    echo [通过] Windows 防火墙已启用
)
exit /b

:Scan_Port443
echo [12/13] 检查 HTTPS 端口 443 连通性...
curl -s -o nul --connect-timeout 3 https://www.baidu.com >nul 2>&1
if errorlevel 1 (
    call :ScanRecord "HTTPS 端口 443 连接失败" "netreset"
) else (
    echo [通过] HTTPS 端口 443 连通正常
)
exit /b

:Scan_MTU
echo [13/13] 检查 MTU 大小...
set "GW="
for /f "tokens=2 delims=:" %%g in ('ipconfig ^| findstr /i "网关 Gateway"') do (
    set "GW=%%g"
    goto :Scan_MTU_done
)
:Scan_MTU_done
set "GW=!GW: =!"
if "!GW!"=="" (
    echo [跳过] 无默认网关，跳过 MTU 检查
    exit /b
)
ping -n 1 -f -l 1472 !GW! >nul 2>&1
if errorlevel 1 (
    call :ScanRecord "MTU 可能过大，1472 字节包无法到达网关" "mtu" ""
) else (
    echo [通过] MTU 正常，1472 字节包可达网关
)
exit /b

:ScanRecord
set /a scan_issue_count+=1
set "scan_issue[!scan_issue_count!]=%~1"
set "scan_fix[!scan_issue_count!]=%~2"
set "scan_manual[!scan_issue_count!]=%~3"
echo [发现] %~1
exit /b

:TimedShutdown
cls
echo ==========================================
echo 定时关机
echo ==========================================
echo 支持格式示例：1h2m3s（1小时2分钟3秒）
echo 可省略部分单位：30m（30分钟）、1h（1小时）、45s（45秒）
echo.
set /p "time_str=请输入定时时间（直接回车取消）："
if "!time_str!"=="" goto CommonToolsMenu
echo 正在解析时间...
:: 调用 PowerShell 解析时间字符串并计算总秒数
set "PS_TIME=%TEMP%\parse_time_tmp.ps1"
if exist "%PS_TIME%" del /f /q "%PS_TIME%" >nul 2>&1
> "%PS_TIME%" echo $s = '%time_str%'
>> "%PS_TIME%" echo $regex = '(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?'
>> "%PS_TIME%" echo if ($s -match $regex) {
>> "%PS_TIME%" echo     $hours = if ($matches[1]) { [int]$matches[1] } else { 0 }
>> "%PS_TIME%" echo     $mins  = if ($matches[2]) { [int]$matches[2] } else { 0 }
>> "%PS_TIME%" echo     $secs  = if ($matches[3]) { [int]$matches[3] } else { 0 }
>> "%PS_TIME%" echo     $total = $hours*3600 + $mins*60 + $secs
>> "%PS_TIME%" echo     Write-Output $total
>> "%PS_TIME%" echo } else {
>> "%PS_TIME%" echo     Write-Output "ERROR"
>> "%PS_TIME%" echo }
for /f "usebackq delims=" %%i in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_TIME%"`) do set "total_sec=%%i"
if exist "%PS_TIME%" del /f /q "%PS_TIME%" >nul 2>&1
if "!total_sec!"=="ERROR" (
    echo 时间格式错误！请使用类似 1h2m3s 的格式。
    pause
    goto TimedShutdown
)
if !total_sec! leq 0 (
    echo 总秒数必须大于0！
    pause
    goto TimedShutdown
)
echo 将在 !total_sec! 秒后自动关机。
choice /C YN /N /M "确认执行定时关机？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
echo 正在设置定时关机...
shutdown /s /t !total_sec!
echo 已设定定时关机。如需取消，请运行 shutdown /a
goto CommonToolsReturn
:CancelShutdown
cls
echo ==========================================
echo 取消关机
echo ==========================================
echo 将执行 shutdown /a 命令，取消已设定的定时关机或重启。
echo.
choice /C YN /N /M "确认取消关机？[Y/N]"
if errorlevel 2 goto CommonToolsMenu
shutdown /a
if errorlevel 1 (
    echo 没有正在进行的关机/重启计划，无需取消。
) else (
    echo 已成功取消关机/重启任务。
)
goto CommonToolsReturn
:End
endlocal
exit