# Docker Management Script for Laravel Car Rental System
# Provides common Docker operations with user-friendly interface

param(
    [Parameter(Position=0)]
    [ValidateSet('start', 'stop', 'restart', 'rebuild', 'logs', 'shell', 'migrate', 'fresh', 'backup', 'status', 'help')]
    [string]$Command = 'help'
)

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Show-Header {
    Write-ColorOutput Cyan "================================================="
    Write-ColorOutput Cyan "  Laravel Car Rental - Docker Manager"
    Write-ColorOutput Cyan "================================================="
    Write-Host ""
}

function Show-Help {
    Show-Header
    Write-ColorOutput Yellow "Usage: .\docker-manage.ps1 [command]"
    Write-Host ""
    Write-ColorOutput Yellow "Available Commands:"
    Write-Host "  start      - Start all Docker containers"
    Write-Host "  stop       - Stop all Docker containers (keeps data)"
    Write-Host "  restart    - Restart all Docker containers"
    Write-Host "  rebuild    - Rebuild and restart containers (after code changes)"
    Write-Host "  logs       - View application logs (real-time)"
    Write-Host "  shell      - Open interactive shell in app container"
    Write-Host "  migrate    - Run database migrations"
    Write-Host "  fresh      - Fresh database migration (WARNING: Deletes data!)"
    Write-Host "  backup     - Create database backup"
    Write-Host "  status     - Show container status and health"
    Write-Host "  help       - Show this help message"
    Write-Host ""
    Write-ColorOutput Yellow "Examples:"
    Write-Host "  .\docker-manage.ps1 start"
    Write-Host "  .\docker-manage.ps1 logs"
    Write-Host "  .\docker-manage.ps1 migrate"
    Write-Host ""
}

function Start-Containers {
    Show-Header
    Write-ColorOutput Yellow "[*] Starting Docker containers..."
    
    docker compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "[OK] Containers started successfully"
        Start-Sleep -Seconds 3
        docker compose ps
        Write-Host ""
        Write-ColorOutput Cyan "Application available at: http://localhost:8080"
    } else {
        Write-ColorOutput Red "[ERROR] Failed to start containers"
        exit 1
    }
}

function Stop-Containers {
    Show-Header
    Write-ColorOutput Yellow "[*] Stopping Docker containers..."
    
    docker compose down
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "[OK] Containers stopped successfully"
        Write-ColorOutput Gray "(Data is preserved. Use 'start' to run again)"
    } else {
        Write-ColorOutput Red "[ERROR] Failed to stop containers"
        exit 1
    }
}

function Restart-Containers {
    Show-Header
    Write-ColorOutput Yellow "[*] Restarting Docker containers..."
    
    docker compose restart
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "[OK] Containers restarted successfully"
        Start-Sleep -Seconds 3
        docker compose ps
    } else {
        Write-ColorOutput Red "[ERROR] Failed to restart containers"
        exit 1
    }
}

function Rebuild-Containers {
    Show-Header
    Write-ColorOutput Yellow "[*] Rebuilding Docker containers..."
    Write-ColorOutput Gray "This will:"
    Write-Host "  1. Stop running containers"
    Write-Host "  2. Rebuild images with latest code"
    Write-Host "  3. Start fresh containers"
    Write-Host ""
    
    $confirm = Read-Host "Continue? (y/n)"
    if ($confirm -ne "y") {
        Write-ColorOutput Yellow "Cancelled."
        return
    }
    
    Write-ColorOutput Yellow "Stopping containers..."
    docker compose down
    
    Write-ColorOutput Yellow "Building images (this may take a few minutes)..."
    docker compose build --no-cache
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "[ERROR] Build failed"
        exit 1
    }
    
    Write-ColorOutput Yellow "Starting new containers..."
    docker compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "[OK] Rebuild complete!"
        Start-Sleep -Seconds 3
        docker compose ps
    } else {
        Write-ColorOutput Red "[ERROR] Failed to start containers"
        exit 1
    }
}

function Show-Logs {
    Show-Header
    Write-ColorOutput Yellow "[*] Showing application logs (Ctrl+C to exit)..."
    Write-Host ""
    
    docker compose logs -f app
}

function Open-Shell {
    Show-Header
    Write-ColorOutput Yellow "[*] Opening shell in app container..."
    Write-ColorOutput Gray "Type 'exit' to leave the shell"
    Write-Host ""
    
    docker compose exec app sh
}

function Run-Migrations {
    Show-Header
    Write-ColorOutput Yellow "[*] Running database migrations..."
    
    docker compose exec app php artisan migrate --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput Green "[OK] Migrations completed"
    } else {
        Write-ColorOutput Red "[ERROR] Migration failed"
        exit 1
    }
}

function Fresh-Database {
    Show-Header
    Write-ColorOutput Red "[WARNING] This will DELETE ALL DATABASE DATA!"
    Write-ColorOutput Yellow "This command will:"
    Write-Host "  1. Drop all tables"
    Write-Host "  2. Re-run all migrations"
    Write-Host "  3. Optionally seed the database"
    Write-Host ""
    
    $confirm = Read-Host "Are you SURE you want to continue? Type 'yes' to confirm"
    if ($confirm -ne "yes") {
        Write-ColorOutput Yellow "Cancelled. Database unchanged."
        return
    }
    
    Write-ColorOutput Yellow "Running fresh migrations..."
    docker compose exec app php artisan migrate:fresh --force
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "[ERROR] Fresh migration failed"
        exit 1
    }
    
    Write-Host ""
    $seed = Read-Host "Do you want to seed the database? (y/n)"
    if ($seed -eq "y") {
        Write-ColorOutput Yellow "Seeding database..."
        docker compose exec app php artisan db:seed --force
    }
    
    Write-ColorOutput Green "[OK] Database refreshed"
}

function Backup-Database {
    Show-Header
    Write-ColorOutput Yellow "[*] Creating database backup..."
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $filename = "backup_${timestamp}.sql"
    
    # Get database credentials from .env
    $env = Get-Content ".env" | ConvertFrom-StringData
    $dbName = $env.DB_DATABASE
    $rootPass = $env.DB_ROOT_PASSWORD
    
    Write-ColorOutput Gray "Backing up database: $dbName"
    
    $result = docker compose exec -T db mysqldump -u root -p"$rootPass" "$dbName" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $result | Out-File -FilePath $filename -Encoding UTF8
        $size = (Get-Item $filename).Length / 1KB
        Write-ColorOutput Green "[OK] Backup created: $filename ($([math]::Round($size, 2)) KB)"
        Write-Host ""
        Write-ColorOutput Cyan "To restore this backup:"
        Write-Host "Get-Content $filename | docker compose exec -T db mysql -u root -p`"$rootPass`" $dbName"
    } else {
        Write-ColorOutput Red "[ERROR] Backup failed: $result"
        exit 1
    }
}

function Show-Status {
    Show-Header
    Write-ColorOutput Yellow "Container Status:"
    Write-Host ""
    
    docker compose ps
    
    Write-Host ""
    Write-ColorOutput Yellow "Health Check:"
    
    # Check app health
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-ColorOutput Green "[OK] Application: Healthy"
        }
    } catch {
        Write-ColorOutput Red "[ERROR] Application: Not responding"
    }
    
    # Check database
    $dbCheck = docker compose exec -T db mysqladmin ping -h localhost -u root -p"$(Get-Content .env | Select-String 'DB_ROOT_PASSWORD' | ForEach-Object { $_.ToString().Split('=')[1] })" 2>&1
    if ($dbCheck -match "alive") {
        Write-ColorOutput Green "[OK] Database: Running"
    } else {
        Write-ColorOutput Red "[ERROR] Database: Not running"
    }
    
    # Check Redis
    $redisCheck = docker compose exec -T redis redis-cli ping 2>&1
    if ($redisCheck -match "PONG") {
        Write-ColorOutput Green "[OK] Redis: Running"
    } else {
        Write-ColorOutput Red "[ERROR] Redis: Not running"
    }
    
    Write-Host ""
    Write-ColorOutput Cyan "Access Points:"
    Write-Host "  - Application:  http://localhost:8080"
    Write-Host "  - Database:     localhost:3307"
    Write-Host "  - Redis:        localhost:6380"
}

# Main command dispatcher
switch ($Command) {
    'start'   { Start-Containers }
    'stop'    { Stop-Containers }
    'restart' { Restart-Containers }
    'rebuild' { Rebuild-Containers }
    'logs'    { Show-Logs }
    'shell'   { Open-Shell }
    'migrate' { Run-Migrations }
    'fresh'   { Fresh-Database }
    'backup'  { Backup-Database }
    'status'  { Show-Status }
    'help'    { Show-Help }
    default   { Show-Help }
}
