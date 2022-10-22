@echo off
"%~dp0Scripts\python.exe" "%~dp0__main__pylint_config.py" %*
exit /b %errorlevel%
