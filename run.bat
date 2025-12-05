@echo off
setlocal enabledelayedexpansion

echo.
echo ======================================
echo 🚀 Starting Momentum Pulse
echo ======================================
echo.

REM Check if venv exists
if not exist "venv" (
    echo ❌ Virtual environment not found
    echo Run setup.bat first
    pause
    exit /b 1
)

REM Activate venv
call venv\Scripts\activate.bat

REM Check if .env exists
if not exist ".env" (
    echo ⚠️  .env file not found
    echo Creating from .env.example...
    copy .env.example .env
    echo 📝 Please edit .env with your credentials
    pause
)

REM Start server
echo.
echo ✅ Starting FastAPI server...
echo.
echo 📡 Webhook URL: http://localhost:8000/webhook
echo 💚 Health Check: http://localhost:8000/health
echo 📊 Active Trades: http://localhost:8000/active-trades
echo.
echo Press Ctrl+C to stop the server
echo.

python -m app.main
