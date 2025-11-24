# Docker Quick Start Script for Windows PowerShell
# This script helps you quickly set up and run the Laravel application with Docker

Write-Host "Laravel Car Rental System - Docker Quick Start" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is installed
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "[OK] Docker installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

try {
    $composeVersion = docker compose version
    Write-Host "[OK] Docker Compose installed: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker Compose is not installed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check if .env exists
if (-Not (Test-Path ".env")) {
    Write-Host ".env file not found. Creating from .env.docker..." -ForegroundColor Yellow
    
    if (Test-Path ".env.docker") {
        Copy-Item ".env.docker" ".env"
        Write-Host "[OK] .env file created successfully" -ForegroundColor Green
        Write-Host ""
        Write-Host "[WARNING] IMPORTANT: Please edit .env and set these values:" -ForegroundColor Yellow
        Write-Host "   - APP_KEY (or we'll generate it after containers start)" -ForegroundColor Yellow
        Write-Host "   - DB_PASSWORD (change from default 'secret')" -ForegroundColor Yellow
        Write-Host "   - DB_ROOT_PASSWORD (change from default 'rootsecret')" -ForegroundColor Yellow
        Write-Host ""
        
        $continue = Read-Host "Do you want to continue with default values for now? (y/n)"
        if ($continue -ne "y") {
            Write-Host "Please edit .env file and run this script again." -ForegroundColor Yellow
            exit 0
        }
    } else {
        Write-Host "[ERROR] .env.docker template not found!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[OK] .env file found" -ForegroundColor Green
}

Write-Host ""
Write-Host "Building Docker images..." -ForegroundColor Yellow
Write-Host "This may take several minutes on first run..." -ForegroundColor Gray

try {
    # Use explicit service name to avoid buildx bake issues
    & docker compose build --progress=plain app 2>&1 | Write-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Build failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Build failed! Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Build completed successfully" -ForegroundColor Green
Write-Host ""

Write-Host "Starting Docker containers..." -ForegroundColor Yellow
try {
    & docker compose up -d 2>&1 | Write-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to start containers!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to start containers! Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Containers started successfully" -ForegroundColor Green
Write-Host ""

Write-Host "Waiting for services to be ready (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Checking APP_KEY..." -ForegroundColor Yellow

# Check if APP_KEY is set
$envContent = Get-Content ".env" -Raw
if ($envContent -match "APP_KEY=base64:kmgc\+nEwNHN0xcORP37dhXrtELuP5yEZO96\+lKY8CRY=") {
    Write-Host "[WARNING] Using default APP_KEY. Generating new one..." -ForegroundColor Yellow
    docker compose exec -T app php artisan key:generate --force
    Write-Host "[OK] New APP_KEY generated" -ForegroundColor Green
} else {
    Write-Host "[OK] APP_KEY already set" -ForegroundColor Green
}

Write-Host ""
Write-Host "Container Status:" -ForegroundColor Yellow
docker compose ps

Write-Host ""
Write-Host "[SUCCESS] Setup complete! Your application is running." -ForegroundColor Green
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Cyan
Write-Host "   - Application:  http://localhost:8080" -ForegroundColor White
Write-Host "   - Database:     localhost:3307 (user: carrent_user, password: secret)" -ForegroundColor White
Write-Host "   - Redis:        localhost:6380" -ForegroundColor White
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Cyan
Write-Host "   - View logs:         docker compose logs -f app" -ForegroundColor White
Write-Host "   - Stop containers:   docker compose down" -ForegroundColor White
Write-Host "   - Restart:           docker compose restart" -ForegroundColor White
Write-Host "   - Run migrations:    docker compose exec app php artisan migrate" -ForegroundColor White
Write-Host "   - Access shell:      docker compose exec app sh" -ForegroundColor White
Write-Host ""
Write-Host "Opening application in browser..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    Start-Process "http://localhost:8080"
} catch {
    Write-Host "[WARNING] Could not open browser automatically" -ForegroundColor Yellow
    Write-Host "Please open http://localhost:8080 manually" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "All done! Happy coding!" -ForegroundColor Green
