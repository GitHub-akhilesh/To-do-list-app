@echo off
SETLOCAL

REM === Config (change if needed) ===
set POSTGRES_DB=todo_db
set POSTGRES_USER=todo_user
set POSTGRES_PASSWORD=todo_pass
set POSTGRES_HOST=localhost
set POSTGRES_PORT=5432

echo Setting environment variables for this CMD session...
echo  POSTGRES_DB=%POSTGRES_DB%
echo  POSTGRES_USER=%POSTGRES_USER%
echo  POSTGRES_PASSWORD=%POSTGRES_PASSWORD%
echo  POSTGRES_HOST=%POSTGRES_HOST%
echo  POSTGRES_PORT=%POSTGRES_PORT%

echo.
echo Installing Python dependencies (if needed)...
pip install -r requirements.txt
IF ERRORLEVEL 1 (
    echo pip install failed. Check Python/pip installation.
    EXIT /B 1
)

echo.
echo Initializing tasks table (init_db)...
python manage.py shell -c "from tasks.db import init_db; init_db()"
IF ERRORLEVEL 1 (
    echo Database initialization failed. Check Postgres connection and env vars.
    EXIT /B 1
)

echo.
echo Starting Django server on http://0.0.0.0:8000 (visit http://127.0.0.1:8000)...
python manage.py runserver 0.0.0.0:8000

ENDLOCAL
