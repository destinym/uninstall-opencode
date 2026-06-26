@echo off
chcp 65001 >nul
:: OpenCode Windows 彻底卸载脚本
:: 适用系统: Windows 10/11
:: ⚠️ 警告: 此操作不可逆，将删除所有项目、会话、配置和数据！

setlocal EnableDelayedExpansion

echo.
echo ========================================
echo ⚠️  OpenCode Windows 彻底卸载脚本
echo ========================================
echo.
echo 此脚本将永久删除:
echo   * OpenCode 应用程序及二进制文件
echo   * 所有项目数据、会话历史、Agent 记忆
echo   * 全局配置 (%%APPDATA%%\opencode)
echo   * 应用数据 (%%LOCALAPPDATA%%\opencode)
echo   * 缓存、日志、临时文件
echo.
echo ⛔ 此操作不可逆！所有项目数据将被永久删除！
echo.

:: ==================== 0. 管理员权限检查 ====================
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARN] 未检测到管理员权限！
    echo 部分卸载操作（如删除 Program Files 文件和 HKLM 注册表项）可能因权限不足而失败。
    echo 建议：右键点击此脚本，选择“以管理员身份运行”。
    echo.
    set /p ADMIN_CONFIRM=是否仍要以当前权限继续运行? (YES/NO): 
    if /i not "!ADMIN_CONFIRM!"=="YES" (
        echo [INFO] 操作已取消
        exit /b 1
    )
    echo.
)

set /p CONFIRM=确认要彻底卸载 OpenCode? 输入 YES 继续: 
if /i not "%CONFIRM%"=="YES" (
    echo [INFO] 操作已取消
    exit /b 0
)

:: ==================== 1. 停止进程 ====================
echo [INFO] 检查并停止 OpenCode 进程...

tasklist /fi "imagename eq opencode.exe" 2>nul | find /i "opencode.exe" >nul
if not errorlevel 1 (
    echo [WARN] 发现运行中的 OpenCode 进程，正在终止...
    taskkill /f /im opencode.exe >nul 2>&1
    :: 使用 ping 代替 timeout，防止在重定向输入时脚本报错退出
    ping -n 3 127.0.0.1 >nul
    echo [INFO] 已终止所有 OpenCode 进程
) else (
    echo [INFO] 未发现运行中的 OpenCode 进程
)

:: ==================== 2. 删除应用程序 ====================
echo [INFO] 删除 OpenCode 应用程序...

for %%p in (
    "%ProgramFiles%\OpenCode"
    "%ProgramFiles(x86)%\OpenCode"
    "%LOCALAPPDATA%\Programs\OpenCode"
) do (
    if exist "%%~p" (
        rd /s /q "%%~p" 2>nul
        echo [INFO] 已删除应用: %%~p
    )
)

:: ==================== 3. 删除二进制文件 ====================
echo [INFO] 删除 OpenCode 二进制文件...

for %%p in (
    "%USERPROFILE%\.local\bin\opencode.exe"
    "%USERPROFILE%\bin\opencode.exe"
    "%LOCALAPPDATA%\Microsoft\WinGet\Packages\opencode.exe"
) do (
    if exist "%%~p" (
        del /f /q "%%~p" 2>nul
        echo [INFO] 已删除二进制: %%~p
    )
)

:: npm 全局安装检查
where npm >nul 2>&1
if not errorlevel 1 (
    npm list -g --depth=0 2>nul | find /i "opencode" >nul
    if not errorlevel 1 (
        echo [WARN] 检测到 npm 全局安装的 OpenCode...
        npm uninstall -g opencode >nul 2>&1
        echo [INFO] 已通过 npm 卸载
    )
)

:: winget 安装检查
where winget >nul 2>&1
if not errorlevel 1 (
    winget list --id opencode 2>nul | find /i "opencode" >nul
    if not errorlevel 1 (
        echo [WARN] 检测到 winget 安装的 OpenCode，执行卸载...
        winget uninstall --id opencode --silent >nul 2>&1
        echo [INFO] 已通过 winget 卸载
    )
)

:: scoop 安装检查
where scoop >nul 2>&1
if not errorlevel 1 (
    scoop list 2>nul | find /i "opencode" >nul
    if not errorlevel 1 (
        echo [WARN] 检测到 scoop 安装的 OpenCode，执行卸载...
        scoop uninstall opencode >nul 2>&1
        echo [INFO] 已通过 scoop 卸载
    )
)

:: choco 安装检查
where choco >nul 2>&1
if not errorlevel 1 (
    choco list --local-only 2>nul | find /i "opencode" >nul
    if not errorlevel 1 (
        echo [WARN] 检测到 chocolatey 安装的 OpenCode，执行卸载...
        choco uninstall opencode -y >nul 2>&1
        echo [INFO] 已通过 chocolatey 卸载
    )
)

:: ==================== 4. 删除数据目录（核心） ====================
echo [INFO] 删除 OpenCode 数据目录...

for %%p in (
    "%LOCALAPPDATA%\opencode"
    "%APPDATA%\opencode"
    "%USERPROFILE%\.opencode"
) do (
    if exist "%%~p" (
        rd /s /q "%%~p" 2>nul
        echo [INFO] 已删除数据目录: %%~p
    )
)

:: ==================== 5. 删除配置文件 ====================
echo [INFO] 删除配置文件...

for %%p in (
    "%USERPROFILE%\.config\opencode"
    "%USERPROFILE%\.opencode.json"
) do (
    if exist "%%~p" (
        if exist "%%~p\" (
            rd /s /q "%%~p" 2>nul
        ) else (
            del /f /q "%%~p" 2>nul
        )
        echo [INFO] 已删除配置: %%~p
    )
)

:: ==================== 6. 删除缓存和日志 ====================
echo [INFO] 删除缓存和日志...

for %%p in (
    "%TEMP%\opencode"
) do (
    if exist "%%~p" (
        rd /s /q "%%~p" 2>nul
        echo [INFO] 已删除: %%~p
    )
)

:: 清理注册表
echo [INFO] 清理注册表项...
reg delete "HKCU\Software\OpenCode" /f >nul 2>&1
reg delete "HKLM\Software\OpenCode" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\OpenCode" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenCode" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenCode" /f >nul 2>&1
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OpenCode" /f >nul 2>&1

:: ==================== 7. 验证卸载结果 ====================
echo [INFO] 验证卸载结果...

set VERIFY_PASS=true

tasklist /fi "imagename eq opencode.exe" 2>nul | find /i "opencode.exe" >nul
if not errorlevel 1 (
    echo [ERROR] ✗ 仍有 OpenCode 进程在运行
    set VERIFY_PASS=false
) else (
    echo [INFO] ✓ 无运行中的 OpenCode 进程
)

where opencode >nul 2>&1
if not errorlevel 1 (
    echo [ERROR] ✗ 仍能找到 opencode 命令
    set VERIFY_PASS=false
) else (
    echo [INFO] ✓ opencode 命令已移除
)

:: ==================== 完成 ====================
echo.
echo ========================================
if "%VERIFY_PASS%"=="true" (
    echo OpenCode 已从 Windows 彻底卸载！
) else (
    echo ⚠️  卸载基本完成，但有残留需手动处理
)
echo ========================================
echo.
echo 后续建议:
echo   * 重启终端或注销重登以确保 PATH 刷新
echo   * 如有 Docker 容器运行 OpenCode，请手动 docker rm
echo   * 检查浏览器扩展中是否有 OpenCode 相关插件
echo.

endlocal
pause
