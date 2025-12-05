@echo off
setlocal enabledelayedexpansion

echo.
echo ======================================
echo ✓ Verifying Setup
echo ======================================
echo.

REM Check Python
echo Checking Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not installed
) else (
    echo ✅ Python installed
    python --version
)
echo.

REM Check pip
echo Checking pip...
pip --version >nul 2>&1
if errorlevel 1 (
    echo ❌ pip not found
) else (
    echo ✅ pip installed
    pip --version
)
echo.

REM Check venv
echo Checking virtual environment...
if exist "venv" (
    echo ✅ Virtual environment exists
) else (
    echo ❌ Virtual environment not found (run setup.bat)
)
echo.

REM Check .env
echo Checking .env file...
if exist ".env" (
    echo ✅ .env file exists
) else (
    echo ❌ .env file not found (run setup.bat)
)
echo.

REM Check requirements.txt
echo Checking requirements.txt...
if exist "requirements.txt" (
    echo ✅ requirements.txt found
) else (
    echo ❌ requirements.txt not found
)
echo.

REM Check app folder
echo Checking app folder...
if exist "app" (
    echo ✅ app folder exists
    if exist "app\main.py" (
        echo ✅ main.py found
    ) else (
        echo ❌ main.py not found
    )
    if exist "app\aliceblue_manager.py" (
        echo ✅ aliceblue_manager.py found
    ) else (
        echo ❌ aliceblue_manager.py not found
    )
    if exist "app\trailing_sl.py" (
        echo ✅ trailing_sl.py found
    ) else (
        echo ❌ trailing_sl.py not found
    )
) else (
    echo ❌ app folder not found
)
echo.

REM Activate venv and check packages
echo Checking installed packages...
call venv\Scripts\activate.bat >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Could not activate venv (run setup.bat)
) else (
    pip list | findstr "fastapi uvicorn pydantic python-dotenv requests" >nul 2>&1
    if errorlevel 1 (
        echo ❌ Some packages missing
    ) else (
        echo ✅ All required packages installed
    )
)
echo.

echo ======================================
echo ✓ Verification Complete
echo ======================================
pause
