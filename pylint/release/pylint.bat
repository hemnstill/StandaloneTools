@echo off
"%~dp0Scripts\python.exe" "%~dp0__main__pylint.py" %*
exit /b %errorlevel%
