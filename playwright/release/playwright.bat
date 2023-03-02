@echo off
"%~dp0Scripts\python.exe" "%~dp0__main__playwright.py" %*
exit /b %errorlevel%
