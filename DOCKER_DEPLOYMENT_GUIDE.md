# Docker Deployment Guide for Laravel Car Rental System

This guide provides comprehensive instructions for deploying your Laravel application using Docker.

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Docker Architecture](#docker-architecture)
4. [Environment Configuration](#environment-configuration)
5. [Building & Running](#building--running)
6. [Database Migrations](#database-migrations)
7. [Vercel Deployment](#vercel-deployment)
8. [Troubleshooting](#troubleshooting)
9. [Production Best Practices](#production-best-practices)

---

## Prerequisites

**Required Software:**
- Docker Desktop (Windows/Mac) or Docker Engine (Linux): v24.0+
- Docker Compose: v2.20+
- Git (for version control)

**Verify Installation:**
```powershell
docker --version
docker-compose --version
```

---

## Quick Start

### 1. **Clone & Setup Environment**
```powershell
# Navigate to project directory
cd C:\Users\T490s Ha\Desktop\Projects\carRent

# Copy Docker environment template
Copy-Item .env.docker .env

# Generate new APP_KEY (if needed)
# You can do this after starting containers
```

### 2. **Configure Environment Variables**
Edit `.env` file and update these critical values:
```env
APP_KEY=base64:YOUR_GENERATED_KEY_HERE
DB_PASSWORD=your_secure_password
DB_ROOT_PASSWORD=your_secure_root_password
APP_URL=http://localhost:8080
```

### 3. **Build & Start Containers**
```powershell
# Build Docker images (first time or after Dockerfile changes)
docker-compose build

# Start all services in detached mode
docker-compose up -d

# View logs
docker-compose logs -f app
```

### 4. **Access Application**
- **Application:** http://localhost:8080
- **Database (MySQL):** localhost:3307
- **Redis:** localhost:6380

---

## Docker Architecture

### Services Overview

#### 1. **App Container** (`carrent-app`)
- **Purpose:** Runs PHP-FPM + Nginx
- **Port:** 8080 → 80
- **Components:**
  - PHP 8.2 with extensions (MySQL, Redis, GD, etc.)
  - Nginx web server
  - Supervisor (process manager)
  - Built TailwindCSS assets

#### 2. **Database Container** (`carrent-db`)
- **Purpose:** MySQL 8.0 database
- **Port:** 3307 → 3306
- **Volume:** Persistent data in `mysql-data`
- **Why:** Stores all application data (users, bookings, cars, etc.)

#### 3. **Redis Container** (`carrent-redis`)
- **Purpose:** Caching & session storage
- **Port:** 6380 → 6379
- **Volume:** Persistent cache in `redis-data`
- **Why:** Improves performance by caching queries and storing sessions

### Multi-Stage Build Explained

**Stage 1 - Node Builder:**
- Installs npm dependencies
- Compiles TailwindCSS and Vite assets
- Output: `public/build` directory with optimized CSS/JS

**Stage 2 - Composer Builder:**
- Installs PHP dependencies
- Optimizes autoloader
- Excludes dev dependencies (smaller image)

**Stage 3 - Production Image:**
- Combines built assets from previous stages
- Installs only runtime dependencies
- Configures PHP-FPM, Nginx, and Supervisor
- Final size: ~150-200MB (optimized)

---

## Environment Configuration

### Development vs Production

**Development `.env`:**
```env
APP_ENV=local
APP_DEBUG=true
DB_HOST=127.0.0.1  # Local database
CACHE_STORE=file
SESSION_DRIVER=file
```

**Production `.env` (Docker):**
```env
APP_ENV=production
APP_DEBUG=false
DB_HOST=db  # Docker service name
CACHE_STORE=redis
SESSION_DRIVER=redis
```

### Important Environment Variables

| Variable | Purpose | Docker Value | Local Value |
|----------|---------|--------------|-------------|
| `DB_HOST` | Database server | `db` | `127.0.0.1` |
| `REDIS_HOST` | Cache server | `redis` | `127.0.0.1` |
| `APP_URL` | Application URL | `http://localhost:8080` | `http://localhost:8000` |
| `CACHE_STORE` | Cache driver | `redis` | `file` |
| `SESSION_DRIVER` | Session storage | `redis` | `file` |

**Why these differences matter:**
- Docker uses service names for internal DNS resolution
- Redis improves performance in containerized environments
- Port mappings avoid conflicts with local services

---

## Building & Running

### Common Commands

```powershell
# Build images (run after Dockerfile changes)
docker-compose build

# Start services
docker-compose up -d

# Stop services (keeps data)
docker-compose down

# Stop and remove volumes (DELETES ALL DATA!)
docker-compose down -v

# View logs
docker-compose logs -f app          # App logs
docker-compose logs -f db           # Database logs
docker-compose logs --tail=100 app  # Last 100 lines

# Restart specific service
docker-compose restart app

# Execute commands in container
docker-compose exec app php artisan migrate
docker-compose exec app php artisan cache:clear
docker-compose exec app sh  # Interactive shell
```

### Rebuilding After Changes

**When to rebuild:**
- Modified `Dockerfile`
- Updated `composer.json` dependencies
- Changed `package.json` dependencies
- Modified Docker configuration files

**How to rebuild:**
```powershell
# Stop containers
docker-compose down

# Rebuild (no cache for clean build)
docker-compose build --no-cache

# Start fresh
docker-compose up -d
```

---

## Database Migrations

### Automatic Migrations
The entrypoint script (`docker/entrypoint.sh`) automatically runs migrations on container startup:
```bash
php artisan migrate --force --no-interaction
```

**Why `--force`?**
- Required in production (bypasses confirmation prompt)
- Safe because we control the environment

### Manual Migration Commands

```powershell
# Run pending migrations
docker-compose exec app php artisan migrate

# Rollback last migration
docker-compose exec app php artisan migrate:rollback

# Reset database (DANGER: Deletes all data!)
docker-compose exec app php artisan migrate:fresh

# Seed database
docker-compose exec app php artisan db:seed

# Fresh migration with seeding
docker-compose exec app php artisan migrate:fresh --seed
```

### Database Access

**Connect with MySQL client:**
```powershell
# Using Docker
docker-compose exec db mysql -u root -p
# Password: DB_ROOT_PASSWORD from .env

# Using local client
mysql -h 127.0.0.1 -P 3307 -u carrent_user -p car_rental_system_db
```

**Backup database:**
```powershell
docker-compose exec db mysqldump -u root -p car_rental_system_db > backup.sql
```

**Restore database:**
```powershell
Get-Content backup.sql | docker-compose exec -T db mysql -u root -p car_rental_system_db
```

---

## Vercel Deployment

### Prerequisites
```powershell
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login
```

### Step-by-Step Deployment

**1. Prepare Environment Variables**

Create a `.env.production` file or configure in Vercel dashboard:
```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_PRODUCTION_KEY
APP_URL=https://your-app.vercel.app

# Database (use managed database like PlanetScale or AWS RDS)
DB_CONNECTION=mysql
DB_HOST=your-database-host.com
DB_PORT=3306
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_secure_password

# Use cookie-based sessions (Vercel is serverless)
SESSION_DRIVER=cookie
CACHE_STORE=array

# Mail configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
```

**2. Update `vercel.json` (Already configured)**

The file is optimized for Laravel:
- Routes static assets correctly
- Sets proper environment variables
- Configures PHP runtime
- Handles all requests through `public/index.php`

**3. Build Script**

Create `build.sh` in project root:
```bash
#!/bin/bash
# Vercel build script

# Install Composer dependencies
composer install --no-dev --optimize-autoloader

# Install npm dependencies
npm ci

# Build assets
npm run build

# Cache Laravel configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

Make it executable:
```powershell
git update-index --chmod=+x build.sh
```

**4. Configure Vercel Project**

In `vercel.json`, the build is configured. In Vercel dashboard, set:

- **Framework Preset:** Other
- **Build Command:** `composer install --no-dev && npm run build`
- **Output Directory:** `public`
- **Install Command:** `npm install`

**5. Environment Variables in Vercel**

Add these in Vercel Dashboard → Settings → Environment Variables:
```
APP_KEY=base64:...
DB_HOST=...
DB_DATABASE=...
DB_USERNAME=...
DB_PASSWORD=...
MAIL_HOST=...
MAIL_USERNAME=...
MAIL_PASSWORD=...
```

**6. Deploy**

```powershell
# Initial deployment
vercel

# Production deployment
vercel --prod
```

### Vercel Limitations & Solutions

**Problem 1: Serverless Functions Have Execution Time Limits**
- **Limit:** 10 seconds (Hobby), 60 seconds (Pro)
- **Solution:** Offload long tasks to external queue services (Laravel Vapor, AWS SQS)

**Problem 2: No Persistent File Storage**
- **Limit:** Files don't persist between requests
- **Solution:** Use S3-compatible storage for uploads:
```env
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=your-bucket
```

**Problem 3: No Managed Database**
- **Limit:** Vercel doesn't provide databases
- **Solution:** Use external services:
  - **MySQL:** PlanetScale, AWS RDS, DigitalOcean
  - **PostgreSQL:** Supabase, Neon, AWS RDS

**Problem 4: Caching Limitations**
- **Limit:** No Redis on serverless
- **Solution:** Use `array` or `database` cache driver:
```env
CACHE_STORE=array  # Fast but per-request
# or
CACHE_STORE=database  # Persistent but requires setup
```

### Recommended: Laravel Vapor for Vercel Alternative
For better Laravel serverless deployment, consider **Laravel Vapor** (AWS):
- Managed queues, databases, caching
- Better Laravel integration
- Automatic scaling
- [https://vapor.laravel.com](https://vapor.laravel.com)

---

## Troubleshooting

### Common Issues

#### 1. **Container Won't Start**
```powershell
# Check logs
docker-compose logs app

# Common causes:
# - Port already in use
# - Invalid .env file
# - Missing environment variables
```

**Solution - Port Conflict:**
```env
# Change port in .env
APP_PORT=8081
```

#### 2. **Permission Denied Errors**
```
Permission denied: /var/www/html/storage/logs/laravel.log
```

**Solution:**
```powershell
# Fix permissions inside container
docker-compose exec app sh -c "chown -R www-data:www-data /var/www/html/storage"
docker-compose exec app sh -c "chmod -R 775 /var/www/html/storage"
```

#### 3. **Database Connection Failed**
```
SQLSTATE[HY000] [2002] Connection refused
```

**Solution:**
```powershell
# Verify DB service is running
docker-compose ps

# Check DB_HOST in .env
# Should be 'db', not '127.0.0.1'

# Wait for database to be ready
docker-compose logs db | Select-String "ready for connections"
```

#### 4. **Assets Not Loading (404)**
```
GET http://localhost:8080/build/assets/app.css 404
```

**Solution:**
```powershell
# Rebuild assets
docker-compose exec app npm run build

# Or rebuild container
docker-compose build --no-cache app
docker-compose up -d
```

#### 5. **Migrations Don't Run**
```powershell
# Manually run migrations
docker-compose exec app php artisan migrate --force

# Check database connection
docker-compose exec app php artisan db:show
```

### Debug Mode

Enable debugging temporarily:
```powershell
# Edit .env
APP_DEBUG=true

# Restart
docker-compose restart app
```

**IMPORTANT:** Always set `APP_DEBUG=false` in production!

---

## Production Best Practices

### Security Checklist

✅ **Environment Variables:**
```env
APP_DEBUG=false  # Never true in production
APP_ENV=production
```

✅ **Strong Passwords:**
```env
DB_PASSWORD=use_strong_random_password_here
DB_ROOT_PASSWORD=different_strong_password
```

✅ **HTTPS Only:**
```env
APP_URL=https://yourdomain.com
SESSION_SECURE_COOKIE=true
```

✅ **Disable Unused Services:**
Comment out unused services in `docker-compose.yml`

### Performance Optimization

**1. Enable OPcache** (Already configured in `docker/php/php.ini`):
```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.validate_timestamps=0  # Production only
```

**2. Use Redis for Sessions:**
```env
CACHE_STORE=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

**3. Optimize Composer Autoloader:**
```powershell
docker-compose exec app composer install --optimize-autoloader --no-dev
```

**4. Cache Laravel Configuration:**
```powershell
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache
```

**5. Limit PHP-FPM Workers** (adjust in `docker/php/php-fpm.conf`):
```ini
pm.max_children = 50      # Based on available RAM
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
```

### Monitoring & Logging

**View Real-time Logs:**
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app

# Filter by error level
docker-compose logs app | Select-String "ERROR"
```

**Laravel Logs Location:**
- Container: `/var/www/html/storage/logs/laravel.log`
- Host: `./storage/logs/laravel.log`

**Export Logs:**
```powershell
docker-compose logs app > app-logs.txt
```

### Backup Strategy

**1. Database Backups:**
```powershell
# Create backup script: backup.ps1
$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$filename = "backup_$date.sql"
docker-compose exec -T db mysqldump -u root -p$env:DB_ROOT_PASSWORD car_rental_system_db > $filename
Write-Host "Backup created: $filename"
```

**2. Uploaded Files:**
```powershell
# Backup storage folder
Compress-Archive -Path .\storage\app\* -DestinationPath "storage_backup_$(Get-Date -Format 'yyyy-MM-dd').zip"
```

**3. Automate with Task Scheduler:**
- Create scheduled task to run `backup.ps1` daily
- Store backups offsite (S3, Google Drive, etc.)

### Scaling Considerations

**Horizontal Scaling:**
```yaml
# docker-compose.yml
services:
  app:
    deploy:
      replicas: 3  # Run 3 instances
```

**Load Balancer:**
Use Nginx or Traefik as reverse proxy for multiple app containers.

**Separate Queue Workers:**
Uncomment the `queue` service in `docker-compose.yml` for background jobs.

---

## Additional Resources

- **Laravel Documentation:** https://laravel.com/docs
- **Docker Documentation:** https://docs.docker.com
- **Docker Compose Reference:** https://docs.docker.com/compose/compose-file/
- **Vercel PHP Runtime:** https://github.com/vercel-community/php

---

## Support & Maintenance

**Common Maintenance Tasks:**

```powershell
# Update dependencies
docker-compose exec app composer update
docker-compose exec app npm update

# Clear all caches
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

# Optimize for production
docker-compose exec app php artisan optimize

# Check application health
docker-compose exec app php artisan about
```

**Container Health Check:**
```powershell
# Check all container status
docker-compose ps

# Test health endpoint
curl http://localhost:8080/health
```

---

**🎉 Your Laravel application is now fully Dockerized and ready for deployment!**

For questions or issues, refer to the troubleshooting section or check application logs.
