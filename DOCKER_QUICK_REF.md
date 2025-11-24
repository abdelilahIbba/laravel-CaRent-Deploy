# 🚀 Docker Quick Reference - Laravel Car Rental System

## Essential Commands

### Starting & Stopping

```powershell
# Quick start (automated)
.\docker-start.ps1

# Start containers
docker-compose up -d
# or
.\docker-manage.ps1 start

# Stop containers (keeps data)
docker-compose down
# or
.\docker-manage.ps1 stop

# Restart containers
docker-compose restart
# or
.\docker-manage.ps1 restart

# Rebuild after code changes
docker-compose down
docker-compose build --no-cache
docker-compose up -d
# or
.\docker-manage.ps1 rebuild
```

### Viewing Logs

```powershell
# All logs (real-time)
docker-compose logs -f

# App logs only
docker-compose logs -f app

# Database logs
docker-compose logs -f db

# Last 100 lines
docker-compose logs --tail=100 app

# Using management script
.\docker-manage.ps1 logs
```

### Database Operations

```powershell
# Run migrations
docker-compose exec app php artisan migrate
# or
.\docker-manage.ps1 migrate

# Fresh migrations (DELETES DATA!)
docker-compose exec app php artisan migrate:fresh
# or
.\docker-manage.ps1 fresh

# Seed database
docker-compose exec app php artisan db:seed

# Create backup
.\docker-manage.ps1 backup

# Access MySQL shell
docker-compose exec db mysql -u root -p
```

### Laravel Artisan Commands

```powershell
# Run any artisan command
docker-compose exec app php artisan [command]

# Examples:
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:list
docker-compose exec app php artisan make:controller CarController
docker-compose exec app php artisan queue:work
docker-compose exec app php artisan storage:link
```

### Container Shell Access

```powershell
# Open shell in app container
docker-compose exec app sh
# or
.\docker-manage.ps1 shell

# Open shell as root
docker-compose exec -u root app sh

# Run single command
docker-compose exec app ls -la
```

### Status & Health

```powershell
# Check container status
docker-compose ps

# Detailed status
.\docker-manage.ps1 status

# Resource usage
docker stats

# Test health endpoint
curl http://localhost:8080/health
```

## Access Points

| Service | URL/Host | Port | Credentials |
|---------|----------|------|-------------|
| Application | http://localhost:8080 | 8080 | - |
| MySQL | localhost | 3307 | user: carrent_user, pass: secret |
| Redis | localhost | 6380 | - |
| Nginx Health | http://localhost:8080/health | 8080 | - |

## File Locations

| Purpose | Container Path | Host Path |
|---------|---------------|-----------|
| Application Root | /var/www/html | ./  |
| Storage (logs, uploads) | /var/www/html/storage | ./storage |
| Public Files | /var/www/html/public | ./public |
| Environment | /var/www/html/.env | ./.env |

## Common Tasks

### Update Dependencies

```powershell
# Update Composer packages
docker-compose exec app composer update

# Update npm packages
docker-compose exec app npm update

# Install new package
docker-compose exec app composer require vendor/package
docker-compose exec app npm install package-name
```

### Clear Caches

```powershell
# Clear all Laravel caches
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

# Clear compiled files
docker-compose exec app php artisan clear-compiled

# Optimize for production
docker-compose exec app php artisan optimize
```

### Build Frontend Assets

```powershell
# Development build
docker-compose exec app npm run dev

# Production build
docker-compose exec app npm run build
```

### Permissions Issues

```powershell
# Fix storage permissions
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chmod -R 775 /var/www/html/storage

# Fix bootstrap cache
docker-compose exec app chown -R www-data:www-data /var/www/html/bootstrap/cache
docker-compose exec app chmod -R 775 /var/www/html/bootstrap/cache
```

## Troubleshooting

### Container Won't Start

```powershell
# Check logs for errors
docker-compose logs app

# Verify .env file exists
Test-Path .env

# Check port conflicts
netstat -ano | findstr :8080
```

### Database Connection Issues

```powershell
# Verify DB container is running
docker-compose ps db

# Check DB_HOST in .env (should be 'db')
Select-String -Path .env -Pattern "DB_HOST"

# Test database connection
docker-compose exec app php artisan db:show
```

### Reset Everything (DANGER!)

```powershell
# Stop and remove all containers, networks, and volumes
docker-compose down -v

# Remove all images
docker-compose down --rmi all -v

# Start fresh
docker-compose build --no-cache
docker-compose up -d
```

## Environment Variables

### Critical Variables

```env
# Application
APP_KEY=base64:...              # Generate with: php artisan key:generate
APP_ENV=production              # or 'local' for development
APP_DEBUG=false                 # NEVER true in production
APP_URL=http://localhost:8080

# Database (Docker)
DB_HOST=db                      # Docker service name, NOT 127.0.0.1
DB_DATABASE=car_rental_system_db
DB_USERNAME=carrent_user
DB_PASSWORD=secret              # Change in production!

# Cache & Sessions
CACHE_STORE=redis               # Use Redis in Docker
SESSION_DRIVER=redis            # Use Redis in Docker
REDIS_HOST=redis                # Docker service name
```

### Switching Between Local and Docker

**Local Development:**
```env
DB_HOST=127.0.0.1
CACHE_STORE=file
SESSION_DRIVER=file
```

**Docker:**
```env
DB_HOST=db
CACHE_STORE=redis
SESSION_DRIVER=redis
```

## Production Deployment

### Vercel Quick Deploy

```powershell
# Install CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

### Pre-deployment Checklist

- [ ] `APP_DEBUG=false` in production .env
- [ ] `APP_ENV=production`
- [ ] Strong passwords for DB
- [ ] HTTPS enabled (`APP_URL=https://...`)
- [ ] External database configured (PlanetScale, AWS RDS)
- [ ] File storage configured (S3, DigitalOcean Spaces)
- [ ] Mail service configured (SendGrid, Mailgun)
- [ ] Backups automated
- [ ] Monitoring set up

## Advanced

### Multiple Environments

```powershell
# Development
docker-compose --env-file .env.local up -d

# Staging
docker-compose --env-file .env.staging up -d

# Production
docker-compose --env-file .env.production up -d
```

### Custom docker-compose Override

Create `docker-compose.override.yml` for local customizations:
```yaml
version: '3.8'
services:
  app:
    ports:
      - "8081:80"  # Custom port
    environment:
      APP_DEBUG: "true"
```

### Export/Import Database

```powershell
# Export
docker-compose exec db mysqldump -u root -p car_rental_system_db > export.sql

# Import
Get-Content export.sql | docker-compose exec -T db mysql -u root -p car_rental_system_db
```

### Run Tests in Container

```powershell
# Run Pest tests
docker-compose exec app php artisan test

# Run specific test
docker-compose exec app php artisan test --filter=UserTest

# Generate coverage
docker-compose exec app php artisan test --coverage
```

## Resources

- **Full Guide**: `DOCKER_DEPLOYMENT_GUIDE.md`
- **README**: `DOCKER_README.md`
- **Laravel Docs**: https://laravel.com/docs
- **Docker Docs**: https://docs.docker.com

---

**💡 Tip**: Use `.\docker-manage.ps1 help` for all available management commands!
