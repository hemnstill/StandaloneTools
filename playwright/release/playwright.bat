@echo off
set PLAYWRIGHT_BROWSERS_PATH=%~dp0ms-playwright
"%~dp0Scripts\python.exe" "%~dp0__main__playwright.py" %*
exit /b %errorlevel%
