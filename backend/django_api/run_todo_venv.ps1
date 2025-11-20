# Param(
#     [string]$PostgresDb = "todo_db",
#     [string]$PostgresUser = "todo_user",
#     [string]$PostgresPassword = "todo_pass",
#     [string]$PostgresHost = "localhost",
#     [string]$PostgresPort = "5432"
# )
Param(
    [string]$PostgresDb = "postgres",          # or todo_db if you created it
    [string]$PostgresUser = "postgres",
    [string]$PostgresPassword = "YOUR_REAL_POSTGRES_PASSWORD_HERE",
    [string]$PostgresHost = "localhost",
    [string]$PostgresPort = "5432"
)


$ErrorActionPreference = "Stop"

Write-Host "=== Todo Project: venv + Django Runner (Windows) ===" -ForegroundColor Cyan
Write-Host "Script directory: $PSScriptRoot" -ForegroundColor DarkGray

# 1) Create virtual environment if it doesn't exist
$venvPath = Join-Path $PSScriptRoot ".venv"

if (-not (Test-Path $venvPath)) {
    Write-Host "`n[1/4] Creating virtual environment at $venvPath ..." -ForegroundColor Cyan
    python -m venv $venvPath
} else {
    Write-Host "`n[1/4] Virtual environment already exists at $venvPath" -ForegroundColor Green
}

# 2) Activate venv
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

if (-not (Test-Path $activateScript)) {
    Write-Host "Could not find venv activation script at $activateScript" -ForegroundColor Red
    exit 1
}

Write-Host "[2/4] Activating virtual environment..." -ForegroundColor Cyan
& $activateScript

# Now we're inside venv: python/pip point to .venv

# 3) Set environment variables for this session
Write-Host "[3/4] Setting PostgreSQL environment variables for this session..." -ForegroundColor Cyan
$env:POSTGRES_DB        = $PostgresDb
$env:POSTGRES_USER      = $PostgresUser
$env:POSTGRES_PASSWORD  = $PostgresPassword
$env:POSTGRES_HOST      = $PostgresHost
$env:POSTGRES_PORT      = $PostgresPort

Write-Host "  POSTGRES_DB=$($env:POSTGRES_DB)"
Write-Host "  POSTGRES_USER=$($env:POSTGRES_USER)"
Write-Host "  POSTGRES_PASSWORD=$($env:POSTGRES_PASSWORD)"
Write-Host "  POSTGRES_HOST=$($env:POSTGRES_HOST)"
Write-Host "  POSTGRES_PORT=$($env:POSTGRES_PORT)"

# 4) Install dependencies inside venv
Write-Host "`nInstalling Python dependencies into the venv (.venv)..." -ForegroundColor Cyan
pip install --upgrade pip
pip install -r (Join-Path $PSScriptRoot "requirements.txt")

# 5) Initialize DB table
Write-Host "`nInitializing tasks table (init_db) in Postgres..." -ForegroundColor Cyan
python manage.py shell -c "from tasks.db import init_db; init_db()"

# 6) Run Django server
Write-Host "`n[4/4] Starting Django server on http://0.0.0.0:8000 (visit http://127.0.0.1:8000) ..." -ForegroundColor Green
python manage.py runserver 0.0.0.0:8000
