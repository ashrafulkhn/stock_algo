@echo off
setlocal enabledelayedexpansion

echo.
echo ======================================
echo Momentum Pulse - Windows Setup
echo ======================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.9+ from python.org
    pause
    exit /b 1
)

echo ✅ Python found
python --version

REM Create virtual environment
if not exist "venv" (
    echo.
    echo 📦 Creating virtual environment...
    python -m venv venv
    if errorlevel 1 (
        echo ❌ Failed to create venv
        pause
        exit /b 1
    )
)

REM Activate virtual environment
echo.
echo 🔄 Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo.
echo 📥 Upgrading pip...
python -m pip install --upgrade pip -q

REM Install dependencies
echo.
echo 📦 Installing dependencies from requirements.txt...
pip install -r requirements.txt
if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

REM Create .env if it doesn't exist
if not exist ".env" (
    echo.
    echo 📝 Creating .env file from .env.example...
    copy .env.example .env
    echo ⚠️  Please edit .env with your AliceBlue credentials
)

echo.
echo ======================================
echo ✅ Setup Complete!
echo ======================================
echo.
echo Next steps:
echo 1. Edit .env with your AliceBlue credentials
echo 2. Run: run.bat (to start the server)
echo 3. Run: test.bat (to test the system)
echo.
pause
