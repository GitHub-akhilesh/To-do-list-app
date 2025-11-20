Param(
    [string]$PostgresDb = "todo_db",
    [string]$PostgresUser = "todo_user",
    [string]$PostgresPassword = "todo_pass",
    [string]$PostgresHost = "localhost",
    [string]$PostgresPort = "5432"
)

Write-Host "Setting environment variables for this PowerShell session..." -ForegroundColor Cyan
$env:POSTGRES_DB = $PostgresDb
$env:POSTGRES_USER = $PostgresUser
$env:POSTGRES_PASSWORD = $PostgresPassword
$env:POSTGRES_HOST = $PostgresHost
$env:POSTGRES_PORT = $PostgresPort

Write-Host "Current settings:" -ForegroundColor Yellow
Write-Host "  POSTGRES_DB=$($env:POSTGRES_DB)"
Write-Host "  POSTGRES_USER=$($env:POSTGRES_USER)"
Write-Host "  POSTGRES_PASSWORD=$($env:POSTGRES_PASSWORD)"
Write-Host "  POSTGRES_HOST=$($env:POSTGRES_HOST)"
Write-Host "  POSTGRES_PORT=$($env:POSTGRES_PORT)"

Write-Host "`nInstalling Python dependencies (if needed)..." -ForegroundColor Cyan
pip install -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Host "pip install failed. Check Python/pip installation." -ForegroundColor Red
    exit 1
}

Write-Host "`nInitializing tasks table (init_db)..." -ForegroundColor Cyan
python manage.py shell -c "from tasks.db import init_db; init_db()"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Database initialization failed. Check Postgres connection and env vars." -ForegroundColor Red
    exit 1
}

Write-Host "`nStarting Django server on http://0.0.0.0:8000 (visit http://127.0.0.1:8000)..." -ForegroundColor Green
python manage.py runserver 0.0.0.0:8000
