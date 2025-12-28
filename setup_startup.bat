@echo off
REM Python Network Dashboard - Startup Task Setup (Batch Version)
REM This creates a scheduled task to run the dashboard at login with admin rights
REM
REM Usage: Right-click this file and select "Run as administrator"

REM Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ============================================================
    echo ERROR: This script must be run as Administrator!
    echo ============================================================
    echo.
    echo Please right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo Python Network Dashboard - Startup Task Setup
echo ============================================================
echo.

REM Get current directory
set "SCRIPT_DIR=%~dp0"
set "VBS_PATH=%SCRIPT_DIR%start_admin.vbs"

REM Check if VBS script exists
if not exist "%VBS_PATH%" (
    echo ERROR: start_admin.vbs not found in %SCRIPT_DIR%
    echo.
    pause
    exit /b 1
)

REM Task configuration
set "TASK_NAME=PythonNetworkDashboard"

echo This will create a scheduled task that:
echo   - Runs at login for your user account
echo   - Starts the dashboard with administrator privileges
echo   - Runs silently in the background
echo.
echo VBS Script location: %VBS_PATH%
echo.

REM Remove existing task if it exists
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Removing existing task...
    schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
)

REM Create the scheduled task
echo Creating scheduled task...
schtasks /create /tn "%TASK_NAME%" ^
    /tr "wscript.exe \"%VBS_PATH%\"" ^
    /sc onlogon ^
    /rl highest ^
    /f >nul 2>&1

if %errorlevel% equ 0 (
    echo.
    echo SUCCESS! Scheduled task created successfully.
    echo.
    echo ============================================================
    echo Configuration Summary:
    echo ============================================================
    echo Task Name:     %TASK_NAME%
    echo Trigger:       At user login
    echo Run Level:     Highest ^(Administrator^)
    echo Status:        Enabled
    echo.
    echo The dashboard will now start automatically when you log in.
    echo.
    echo To manage the task:
    echo   - Open Task Scheduler ^(taskschd.msc^)
    echo   - Look for '%TASK_NAME%' in Task Scheduler Library
    echo.
    echo To disable auto-start:
    echo   schtasks /change /tn "%TASK_NAME%" /disable
    echo.
    echo To remove auto-start:
    echo   schtasks /delete /tn "%TASK_NAME%" /f
    echo.
    echo ============================================================
) else (
    echo.
    echo ERROR: Failed to create scheduled task
    echo Error code: %errorlevel%
    echo.
)

echo.
pause
