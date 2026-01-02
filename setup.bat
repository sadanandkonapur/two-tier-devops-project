@echo off
REM Two-Tier DevOps Project Setup Script
REM This script checks for Docker and helps with installation

echo.
echo ========================================
echo Two-Tier DevOps Project Setup
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed!
    echo.
    echo Please download Docker Desktop from:
    echo https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe
    echo.
    echo After installation:
    echo 1. Restart your computer
    echo 2. Run this script again
    echo.
    pause
    exit /b 1
)

echo [OK] Docker found: 
docker --version
echo.

REM Check if Docker daemon is running
docker ps >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker daemon is not running!
    echo.
    echo Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

echo [OK] Docker daemon is running
echo.

REM Start the application
echo [INFO] Starting the two-tier application...
echo.

cd /d "%~dp0"

docker compose down -q
timeout /t 2 /nobreak >nul

docker compose up -d

echo.
echo ========================================
echo Application Starting...
echo ========================================
echo.
echo Web Application:   http://localhost:5000
echo MySQL Database:    localhost:3306
echo.
echo Containers status:
docker compose ps
echo.
echo [INFO] Wait 30 seconds for MySQL to initialize...
echo [INFO] Then access http://localhost:5000 in your browser
echo.
echo To view logs, run: docker compose logs -f
echo To stop, run: docker compose down
echo.
pause
