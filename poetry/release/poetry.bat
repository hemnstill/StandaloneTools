@echo off
"%~dp0Scripts\python.exe" "%~dp0__main__.py" %*
exit /b %errorlevel%
