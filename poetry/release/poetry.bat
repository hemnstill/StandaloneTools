@echo off
"%~dp0Python\python.exe" "%~dp0__main__.py" %*
exit /b %errorlevel%
