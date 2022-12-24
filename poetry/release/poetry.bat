@echo off
"%~dp0Scripts\python.exe" "%~dp0__main__poetry.py" %*
exit /b %errorlevel%
