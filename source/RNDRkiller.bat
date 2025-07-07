@echo off
setlocal

:: Where am i?
set SCRIPT_DIR=%~dp0
set PS_SCRIPT=%SCRIPT_DIR%RNDRkiller.ps1

:: Run PS script.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

endlocal
