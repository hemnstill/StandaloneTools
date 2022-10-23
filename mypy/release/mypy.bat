@echo off
"%~dp0Scripts\python.exe" "%~dp0__main__mypy.py" %*
exit /b %errorlevel%
