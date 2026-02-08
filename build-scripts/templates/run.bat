@echo off
REM run.bat - Launcher script for AeroBeat Windows bundle
REM 
REM This script:
REM   - Sets up PYTHONPATH for bundled Python
REM   - Checks for camera devices
REM   - Starts Python sidecar (MediaPipe server)
REM   - Launches Godot game
REM   - Cleans up sidecar on exit
REM
title AeroBeat - Air Drumming Game

REM Configuration
set "USE_MOCK=false"
set "CAMERA_ID=0"
set "SKIP_CAMERA_CHECK=false"
set "SIDECAR_PID="

REM Parse arguments
:parse_args
if "%~1"=="" goto :args_done
if /I "%~1"=="--mock" (
    set "USE_MOCK=true"
    shift
    goto :parse_args
)
if /I "%~1"=="--camera" (
    set "CAMERA_ID=%~2"
    shift
    shift
    goto :parse_args
)
if /I "%~1"=="--no-camera" (
    set "SKIP_CAMERA_CHECK=true"
    shift
    goto :parse_args
)
if /I "%~1"=="--help" goto :show_help
if /I "%~1"=="-h" goto :show_help
if /I "%~1"=="/h" goto :show_help
if /I "%~1"=="/help" goto :show_help
echo Unknown option: %~1
echo Run 'run.bat --help' for usage information.
exit /b 1

:show_help
echo AeroBeat Launcher
echo.
echo Usage: run.bat [options]
echo.
echo Options:
echo   --mock          Use mock server for testing (no camera needed)
echo   --camera N      Use camera device N (default: 0)
echo   --no-camera     Skip camera detection (not recommended)
echo   --help, -h      Show this help message
echo.
echo Environment Variables:
echo   AEROBEAT_CAMERA    Camera device ID (default: 0)
echo   AEROBEAT_MOCK      Set to 1 to use mock server
echo.
exit /b 0

:args_done

REM Check environment variables
if not "%AEROBEAT_CAMERA%"=="" set "CAMERA_ID=%AEROBEAT_CAMERA%"
if "%AEROBEAT_MOCK%"=="1" set "USE_MOCK=true"

REM Get script directory
set "BUNDLE_DIR=%~dp0"
set "BUNDLE_DIR=%BUNDLE_DIR:~0,-1%"

REM Print banner
echo.
echo     ___                   ____            _   
echo    /   ^|  _______  ______/ __ )________ _^| ^|_
echo   / /^| ^| / ___/ / / / __  / __/ ___/ _  ^| __/
echo  / ___ ^|/ /  / /_/ / /_/ / /_/ /  /  __/ /_  
echo /_/  ^|_/_/   \__, /_____/_____/   \___/\__/  
echo            /____/                            
echo.
echo Air Drumming Game - Windows Bundle
echo.

REM Step 1: Set up Python environment
echo [INFO] Setting up Python environment...

set "PYTHON_DIR=%BUNDLE_DIR%\python"
if exist "%PYTHON_DIR%\python.exe" (
    set "PYTHON_EXEC=%PYTHON_DIR%\python.exe"
    set "PYTHONPATH=%PYTHON_DIR%\Lib;%PYTHON_DIR%\Lib\site-packages;%PYTHONPATH%"
) else (
    echo [WARN] No bundled Python found, checking system Python...
    where python >nul 2>&1
    if %ERRORLEVEL%==0 (
        for /f "tokens=*" %%a in ('python --version 2^>^&1') do set "PYTHON_VERSION=%%a"
        echo [OK] Python ready: %PYTHON_VERSION%
        set "PYTHON_EXEC=python"
    ) else (
        echo [ERROR] Python is not available. Please install Python 3.11 or later.
        exit /b 1
    )
)

REM Verify Python works
"%PYTHON_EXEC%" --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python is not working properly.
    exit /b 1
)
for /f "tokens=*" %%a in ('"%PYTHON_EXEC%" --version 2^>^&1') do set "PYTHON_VERSION=%%a"
echo [OK] %PYTHON_VERSION%

REM Step 2: Check for camera devices
if "%SKIP_CAMERA_CHECK%"=="false" (
    if "%USE_MOCK%"=="false" (
        echo [INFO] Checking camera devices...
        
        REM Use PowerShell to enumerate cameras
        powershell -NoProfile -Command "Get-CimInstance Win32_PnPEntity ^| Where-Object {$_.PNPClass -eq 'Camera' -or $_.Name -like '*camera*' -or $_.Name -like '*webcam*'} ^| Select-Object Name" >"%TEMP%\cameras.txt" 2>nul
        
        for /f %%a in ('type "%TEMP%\cameras.txt" ^| find /c /v ""') do set "CAMERA_COUNT=%%a"
        REM Subtract 2 for headers
        set /a CAMERA_COUNT=CAMERA_COUNT-2
        
        if %CAMERA_COUNT% GTR 0 (
            echo [OK] Found %CAMERA_COUNT% camera device(s)
            type "%TEMP%\cameras.txt" | findstr /v "^Name$" | findstr /v "^-"
        ) else (
            echo [WARN] No camera devices detected
            echo [WARN] You can use --mock flag to run without a camera
            echo.
            choice /C YN /M "Continue anyway"
            if %ERRORLEVEL%==2 exit /b 1
        )
        
        del "%TEMP%\cameras.txt" 2>nul
    )
)

if "%USE_MOCK%"=="true" (
    echo [INFO] Using mock server (no camera needed)
)

REM Step 3: Start Python sidecar
echo [INFO] Starting MediaPipe sidecar...

set "SIDECAR_DIR=%BUNDLE_DIR%\python_mediapipe"
set "SIDECAR_LOG=%BUNDLE_DIR%\sidecar.log"

if "%USE_MOCK%"=="true" (
    if exist "%SIDECAR_DIR%\mock_server.py" (
        echo [INFO] Starting mock server...
        start /B "AeroBeat Sidecar" "%PYTHON_EXEC%" "%SIDECAR_DIR%\mock_server.py" >"%SIDECAR_LOG%" 2>&1
        for /f "tokens=2" %%a in ('tasklist /fi "imagename eq %PYTHON_EXEC%" /fo list ^| findstr /i "PID:"') do set "SIDECAR_PID=%%a"
    ) else (
        echo [ERROR] Mock server not found at %SIDECAR_DIR%\mock_server.py
        exit /b 1
    )
) else (
    if exist "%SIDECAR_DIR%\main.py" (
        echo [INFO] Starting MediaPipe server (camera: %CAMERA_ID%)...
        start /B "AeroBeat Sidecar" "%PYTHON_EXEC%" "%SIDECAR_DIR%\main.py" --camera %CAMERA_ID% >"%SIDECAR_LOG%" 2>&1
        for /f "tokens=2" %%a in ('tasklist /fi "imagename eq python.exe" /fo list ^| findstr /i "PID:"') do set "SIDECAR_PID=%%a"
    ) else (
        echo [ERROR] MediaPipe server not found at %SIDECAR_DIR%\main.py
        exit /b 1
    )
)

REM Wait for sidecar to start
timeout /t 2 /nobreak >nul

REM Check if sidecar is running
tasklist /fi "imagename eq python.exe" /fo csv /nh | findstr /i "python" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Sidecar failed to start. Check %SIDECAR_LOG% for details.
    if exist "%SIDECAR_LOG%" type "%SIDECAR_LOG%"
    exit /b 1
)
echo [OK] Sidecar started

REM Show recent logs
if exist "%SIDECAR_LOG%" (
    echo Recent logs:
    type "%SIDECAR_LOG%" | findstr /n "." | findstr "^1:" | sed "s/^[0-9]*://"
    type "%SIDECAR_LOG%" | findstr /n "." | findstr "^2:" | sed "s/^[0-9]*://"
    type "%SIDECAR_LOG%" | findstr /n "." | findstr "^3:" | sed "s/^[0-9]*://"
)

REM Step 4: Launch Godot game
echo [INFO] Starting AeroBeat...
echo.

set "GAME_EXEC=%BUNDLE_DIR%\AeroBeat.exe"

if not exist "%GAME_EXEC%" (
    echo [ERROR] Game executable not found: %GAME_EXEC%
    taskkill /f /im python.exe >nul 2>&1
    exit /b 1
)

echo [INFO] Launching game... (press Ctrl+C to quit)
echo.

REM Run game
"%GAME_EXEC%"
set "GAME_EXIT=%ERRORLEVEL%"

echo.

REM Handle exit
if %GAME_EXIT%==0 (
    echo [OK] Game exited normally
) else (
    if %GAME_EXIT%==-1073741510 (
        echo [INFO] Game interrupted (Ctrl+C)
    ) else (
        echo [WARN] Game exited with code %GAME_EXIT%
    )
)

REM Cleanup
echo [INFO] Cleaning up...
taskkill /f /im python.exe >nul 2>&1

exit /b %GAME_EXIT%
