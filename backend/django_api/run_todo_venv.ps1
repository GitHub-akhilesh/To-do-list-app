# ================================
#  PostgreSQL (DISABLED)
# ================================
# Param(
#     [string]$PostgresDb = "postgres",
#     [string]$PostgresUser = "postgres",
#     [string]$PostgresPassword = "YOUR_REAL_POSTGRES_PASSWORD_HERE",
#     [string]$PostgresHost = "localhost",
#     [string]$PostgresPort = "5432"
# )
#
# $env:POSTGRES_DB        = $PostgresDb
# $env:POSTGRES_USER      = $PostgresUser
# $env:POSTGRES_PASSWORD  = $PostgresPassword
# $env:POSTGRES_HOST      = $PostgresHost
# $env:POSTGRES_PORT      = $PostgresPort
#
# Write-Host "  POSTGRES_DB=$($env:POSTGRES_DB)"
# Write-Host "  POSTGRES_USER=$($env:POSTGRES_USER)"
# Write-Host "  POSTGRES_PASSWORD=$($env:POSTGRES_PASSWORD)"
# Write-Host "  POSTGRES_HOST=$($env:POSTGRES_HOST)"
# Write-Host "  POSTGRES_PORT=$($env:POSTGRES_PORT)"


# ================================
#  MySQL (ENABLED)
# ================================
Param(
    [string]$MySqlDb = "todo_db",
    [string]$MySqlUser = "root",
    [string]$MySqlPassword = "root@123",
    [string]$MySqlHost = "localhost",
    [string]$MySqlPort = "3306"
)

$env:MYSQL_DB        = $MySqlDb
$env:MYSQL_USER      = $MySqlUser
$env:MYSQL_PASSWORD  = $MySqlPassword
$env:MYSQL_HOST      = $MySqlHost
$env:MYSQL_PORT      = $MySqlPort

Write-Host "=== Todo Project: venv + Django Runner (Windows / MySQL Mode) ===" -ForegroundColor Cyan
Write-Host "Script directory: $PSScriptRoot" -ForegroundColor DarkGray

Write-Host "`n[MySQL ENV] Using these credentials:" -ForegroundColor Yellow
Write-Host "  MYSQL_DB=$($env:MYSQL_DB)"
Write-Host "  MYSQL_USER=$($env:MYSQL_USER)"
Write-Host "  MYSQL_PASSWORD=$($env:MYSQL_PASSWORD)"
Write-Host "  MYSQL_HOST=$($env:MYSQL_HOST)"
Write-Host "  MYSQL_PORT=$($env:MYSQL_PORT)"


# ================================
# 1) Create virtual environment
# ================================
$ErrorActionPreference = "Stop"
$venvPath = Join-Path $PSScriptRoot ".venv"

if (-not (Test-Path $venvPath)) {
    Write-Host "`n[1/4] Creating virtual environment at $venvPath ..." -ForegroundColor Cyan
    python -m venv $venvPath
} else {
    Write-Host "`n[1/4] Virtual environment already exists at $venvPath" -ForegroundColor Green
}

# ================================
# 2) Activate virtual environment
# ================================
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"

if (-not (Test-Path $activateScript)) {
    Write-Host "Could not find venv activation script at $activateScript" -ForegroundColor Red
    exit 1
}

Write-Host "[2/4] Activating virtual environment..." -ForegroundColor Cyan
& $activateScript

# ================================
# 3) Install dependencies
# ================================
Write-Host "`nInstalling Python dependencies into the venv (.venv)..." -ForegroundColor Cyan
pip install --upgrade pip
pip install -r (Join-Path $PSScriptRoot "requirements.txt")

# ================================
# 4) Initialize DB table (raw SQL)
# ================================
Write-Host "`nInitializing tasks table (init_db) in MySQL..." -ForegroundColor Cyan
python manage.py shell -c "from tasks.db import init_db; init_db()"

# ================================
# 5) Run Django server
# ================================
Write-Host "`n[4/4] Starting Django server on http://0.0.0.0:8000 (visit http://127.0.0.1:8000) ..." -ForegroundColor Green
python manage.py runserver 0.0.0.0:8000
