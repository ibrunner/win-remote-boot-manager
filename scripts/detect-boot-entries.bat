@echo off
REM Detect available boot entries
REM This script requires administrator privileges

echo Detecting boot entries...
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script requires administrator privileges.
    echo Please run as administrator.
    pause
    exit /b 1
)

echo Available firmware boot entries:
echo ================================
bcdedit /enum firmware

echo.
echo ================================
echo.
echo Look for entries like:
echo   - "ubuntu" or "Linux Boot Manager" for Ubuntu
echo   - "Windows Boot Manager" for Windows
echo.
echo Copy the identifier (GUID in curly braces) for your .env file
echo.
pause
