@echo off
setlocal enabledelayedexpansion

echo.
echo ======================================
echo 🧪 Momentum Pulse - Test Suite
echo ======================================
echo.

set SERVER=http://localhost:8000

REM Check if server is running
echo Checking if server is running...
curl -s %SERVER%/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Server is not running!
    echo Start the server with: run.bat
    pause
    exit /b 1
)

echo ✅ Server is running
echo.

:menu
cls
echo.
echo ======================================
echo 🧪 Test Menu
echo ======================================
echo.
echo 1. Health Check
echo 2. Dry-Run: Buy CE (Call) Option
echo 3. Dry-Run: Buy PE (Put) Option
echo 4. View Active Trades
echo 5. Manual Exit Trade
echo 6. Load Test (10 Orders)
echo 7. Run All Tests
echo 8. Exit
echo.
set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" goto health_check
if "%choice%"=="2" goto test_ce
if "%choice%"=="3" goto test_pe
if "%choice%"=="4" goto view_trades
if "%choice%"=="5" goto manual_exit
if "%choice%"=="6" goto load_test
if "%choice%"=="7" goto run_all
if "%choice%"=="8" exit /b 0

echo Invalid choice
pause
goto menu

:health_check
cls
echo.
echo 🔍 Running Health Check...
echo.
curl -s %SERVER%/health | python -m json.tool
echo.
pause
goto menu

:test_ce
cls
echo.
echo 📈 Testing CE (Call) Option Order...
echo.
curl -X POST %SERVER%/webhook ^
  -H "Content-Type: application/json" ^
  -d "{\"symbol\": \"NIFTY50\", \"option_type\": \"CE\", \"strike\": \"21000\", \"qty\": 1, \"sl_percent\": 10.0}" ^
  | python -m json.tool
echo.
pause
goto menu

:test_pe
cls
echo.
echo 📉 Testing PE (Put) Option Order...
echo.
curl -X POST %SERVER%/webhook ^
  -H "Content-Type: application/json" ^
  -d "{\"symbol\": \"BANKNIFTY\", \"option_type\": \"PE\", \"strike\": \"48000\", \"qty\": 1, \"sl_percent\": 10.0}" ^
  | python -m json.tool
echo.
pause
goto menu

:view_trades
cls
echo.
echo 📊 Active Trades...
echo.
curl -s %SERVER%/active-trades | python -m json.tool
echo.
pause
goto menu

:manual_exit
cls
echo.
set /p symbol="Enter symbol to exit (e.g., NIFTY50): "
echo.
echo Exiting trade for %symbol%...
echo.
curl -X POST %SERVER%/exit/%symbol% | python -m json.tool
echo.
pause
goto menu

:load_test
cls
echo.
echo 🔄 Running Load Test (10 Orders)...
echo.

set symbols[0]=NIFTY50
set symbols[1]=BANKNIFTY
set symbols[2]=RELIANCE
set symbols[3]=TCS
set symbols[4]=INFY
set symbols[5]=WIPRO
set symbols[6]=HDFC
set symbols[7]=ICICIBANK
set symbols[8]=MARUTI
set symbols[9]=SBIN

for /l %%i in (0,1,9) do (
    echo.
    echo [Test %%i+1/10] Symbol: !symbols[%%i]!
    curl -s -X POST %SERVER%/webhook ^
      -H "Content-Type: application/json" ^
      -d "{\"symbol\": \"!symbols[%%i]!\", \"option_type\": \"CE\", \"strike\": \"ATM\", \"qty\": 1, \"sl_percent\": 10.0}" ^
      | python -m json.tool
    timeout /t 1 /nobreak >nul
)

echo.
echo ✅ Load test completed
echo.
pause
goto menu

:run_all
cls
echo.
echo ======================================
echo Running All Tests...
echo ======================================
echo.

echo Test 1: Health Check
echo ========================
curl -s %SERVER%/health | python -m json.tool
echo.
timeout /t 2 /nobreak >nul

echo Test 2: CE Option Order
echo ========================
curl -s -X POST %SERVER%/webhook ^
  -H "Content-Type: application/json" ^
  -d "{\"symbol\": \"NIFTY50\", \"option_type\": \"CE\", \"strike\": \"21000\", \"qty\": 1, \"sl_percent\": 10.0}" ^
  | python -m json.tool
echo.
timeout /t 2 /nobreak >nul

echo Test 3: PE Option Order
echo ========================
curl -s -X POST %SERVER%/webhook ^
  -H "Content-Type: application/json" ^
  -d "{\"symbol\": \"BANKNIFTY\", \"option_type\": \"PE\", \"strike\": \"48000\", \"qty\": 1, \"sl_percent\": 10.0}" ^
  | python -m json.tool
echo.
timeout /t 2 /nobreak >nul

echo Test 4: View Active Trades
echo ========================
curl -s %SERVER%/active-trades | python -m json.tool
echo.

echo ✅ All tests completed
echo.
pause
goto menu
