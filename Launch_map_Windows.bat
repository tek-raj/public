@echo off
REM Launches a local map server using the BUNDLED portable Python (auto-detected
REM in a "python-*-embed*" subfolder next to this file) - no install needed on
REM the recipient's machine. Then opens the map in your default browser.

set PORT=8000

REM %~dp0 = the folder this .bat file is running from, so it works no matter
REM where the project folder is moved to.
cd /d "%~dp0"

REM Look for the embedded python folder - either plain "python" or a
REM versioned folder like "python-3.13.14-embed-amd64"
set PYEXE=
if exist "%~dp0python\python.exe" set PYEXE=%~dp0python\python.exe

if not defined PYEXE (
    for /d %%i in ("%~dp0python-*-embed*") do set PYEXE=%%i\python.exe
)

if not exist "%PYEXE%" (
    echo ERROR: Could not find python.exe in a "python" or "python-*-embed*" folder next to this script.
    echo Make sure the embedded Python folder is in the same directory as this .bat file.
    pause
    exit /b 1
)

echo Starting local server (bundled Python: %PYEXE%)...
start "Wet Tropics Map Server" cmd /k ""%PYEXE%" -m http.server %PORT%"

REM Give the server a couple seconds to spin up before opening the browser
timeout /t 2 /nobreak >nul

echo Opening map in browser...
REM %RANDOM% + %TIME% makes the URL different every run, so the browser can
REM never serve a stale cached copy of index_long.html or its assets.
set CACHEBUST=%RANDOM%%TIME:~6,5%
start http://localhost:%PORT%/index_long.html?nocache=%CACHEBUST%
