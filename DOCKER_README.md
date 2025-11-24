# 🚗 Laravel Car Rental System - Docker Setup

Complete Docker containerization for Laravel Blade + TailwindCSS application with production-ready configurations.

## 📦 What's Included

### Docker Services
- **App Container**: PHP 8.2-FPM + Nginx + Supervisor
- **MySQL 8.0**: Persistent database with optimized configuration
- **Redis 7**: High-performance caching and session storage
- **Optional**: PostgreSQL, Queue Workers, Task Scheduler

### Features
✅ Multi-stage build for optimized image size  
✅ Automatic migrations on startup  
✅ Pre-compiled TailwindCSS assets  
✅ Production-ready PHP/Nginx configuration  
✅ Health checks and monitoring  
✅ Persistent data volumes  
✅ Development and production profiles  

---

## 🚀 Quick Start

### Prerequisites
- **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)
- **Docker Compose** v2.20+

### 1. Initial Setup
```powershell
# Clone the repository (if not already done)
git clone <your-repo-url>
cd carRent

# Run the automated setup script
.\docker-start.ps1
```

This script will:
1. Check Docker installation
2. Create `.env` from template
3. Build Docker images
4. Start all containers
5. Generate APP_KEY
6. Open the application in your browser

### 2. Manual Setup (Alternative)
```powershell
# Copy environment file
Copy-Item .env.docker .env

# Edit .env and set your values
# Especially: APP_KEY, DB_PASSWORD, DB_ROOT_PASSWORD

# Build and start
docker-compose build
docker-compose up -d

# Generate application key
docker-compose exec app php artisan key:generate

# Run migrations
docker-compose exec app php artisan migrate
```

### 3. Access Your Application
- **Application**: http://localhost:8080
- **Database**: localhost:3307 (MySQL)
- **Redis**: localhost:6380

---

## 🛠️ Management Commands

Use the convenient management script:

```powershell
# Start containers
.\docker-manage.ps1 start

# Stop containers
.\docker-manage.ps1 stop

# View logs
.\docker-manage.ps1 logs

# Run migrations
.\docker-manage.ps1 migrate

# Open shell
.\docker-manage.ps1 shell

# Check status
.\docker-manage.ps1 status

# See all commands
.\docker-manage.ps1 help
```

### Manual Docker Commands

```powershell
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f app

# Execute Artisan commands
docker-compose exec app php artisan migrate
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan db:seed

# Access container shell
docker-compose exec app sh

# Rebuild after code changes
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 📁 Docker File Structure

```
carRent/
├── Dockerfile                     # Multi-stage production build
├── docker-compose.yml             # Service orchestration
├── .dockerignore                  # Build exclusions
├── .env.docker                    # Environment template
├── docker-start.ps1               # Quick start script
├── docker-manage.ps1              # Management utility
└── docker/
    ├── entrypoint.sh              # Container initialization
    ├── php/
    │   ├── php.ini                # PHP configuration
    │   └── php-fpm.conf           # PHP-FPM pool settings
    ├── nginx/
    │   ├── nginx.conf             # Nginx main config
    │   └── default.conf           # Laravel server block
    ├── supervisor/
    │   └── supervisord.conf       # Process manager
    └── mysql/
        └── my.cnf                 # MySQL optimization
```

---

## 🔧 Configuration Details

### Environment Variables

**Development (Local)**:
```env
APP_ENV=local
APP_DEBUG=true
DB_HOST=127.0.0.1
CACHE_STORE=file
SESSION_DRIVER=file
```

**Production (Docker)**:
```env
APP_ENV=production
APP_DEBUG=false
DB_HOST=db              # Docker service name
CACHE_STORE=redis       # Use Redis for caching
SESSION_DRIVER=redis    # Use Redis for sessions
```

### Port Mappings

| Service | Container Port | Host Port | Environment Variable |
|---------|---------------|-----------|---------------------|
| App (Nginx) | 80 | 8080 | `APP_PORT` |
| MySQL | 3306 | 3307 | `DB_EXTERNAL_PORT` |
| Redis | 6379 | 6380 | `REDIS_EXTERNAL_PORT` |

To change ports, edit `.env`:
```env
APP_PORT=8081          # Change from 8080
DB_EXTERNAL_PORT=3308  # Change from 3307
```

### Volumes (Persistent Data)

```yaml
mysql-data:     # Database files (survives container restarts)
redis-data:     # Redis persistence
./storage:      # Application uploads and logs
```

**To completely reset**:
```powershell
docker-compose down -v  # WARNING: Deletes all data!
```

---

## 📊 Database Management

### Migrations

```powershell
# Run pending migrations
docker-compose exec app php artisan migrate

# Rollback last migration
docker-compose exec app php artisan migrate:rollback

# Fresh migration (WARNING: Deletes all data)
docker-compose exec app php artisan migrate:fresh

# Fresh with seeding
docker-compose exec app php artisan migrate:fresh --seed
```

### Backups

```powershell
# Create backup
.\docker-manage.ps1 backup

# Manual backup
docker-compose exec db mysqldump -u root -p car_rental_system_db > backup.sql

# Restore backup
Get-Content backup.sql | docker-compose exec -T db mysql -u root -p car_rental_system_db
```

### Direct Database Access

```powershell
# Using Docker
docker-compose exec db mysql -u root -p

# Using local MySQL client
mysql -h 127.0.0.1 -P 3307 -u carrent_user -p car_rental_system_db
```

---

## 🌐 Vercel Deployment

### Quick Deploy to Vercel

```powershell
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel --prod
```

### Environment Variables for Vercel

Set these in Vercel Dashboard → Settings → Environment Variables:

```env
APP_KEY=base64:your_generated_key_here
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-app.vercel.app

# Use external database (PlanetScale, AWS RDS, etc.)
DB_CONNECTION=mysql
DB_HOST=your-database-host.com
DB_DATABASE=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password

# Serverless-compatible drivers
SESSION_DRIVER=cookie
CACHE_STORE=array

# Mail configuration
MAIL_MAILER=smtp
MAIL_HOST=smtp.sendgrid.net
MAIL_USERNAME=apikey
MAIL_PASSWORD=your_sendgrid_api_key
```

### Important Vercel Considerations

1. **Serverless Limitations**:
   - No persistent file storage (use S3 for uploads)
   - No background workers (use external queue services)
   - 10-second execution limit (Hobby plan)

2. **Database**: Vercel doesn't provide databases. Use:
   - **PlanetScale** (MySQL, free tier available)
   - **Supabase** (PostgreSQL, free tier)
   - **AWS RDS** (Production scale)

3. **File Storage**: Configure S3 for uploads:
   ```env
   FILESYSTEM_DISK=s3
   AWS_ACCESS_KEY_ID=your_key
   AWS_SECRET_ACCESS_KEY=your_secret
   AWS_DEFAULT_REGION=us-east-1
   AWS_BUCKET=your-bucket-name
   ```

4. **Build Configuration**: Already configured in `vercel.json`

---

## 🐛 Troubleshooting

### Common Issues

#### Port Already in Use
```powershell
# Change the port in .env
APP_PORT=8081

# Restart
docker-compose down
docker-compose up -d
```

#### Database Connection Failed
```powershell
# Check if DB container is running
docker-compose ps

# Verify DB_HOST in .env is set to 'db'
# NOT '127.0.0.1' or 'localhost'

# Check database logs
docker-compose logs db
```

#### Permission Denied Errors
```powershell
# Fix storage permissions
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chmod -R 775 /var/www/html/storage
```

#### Assets Not Loading (404)
```powershell
# Rebuild container to re-compile assets
docker-compose down
docker-compose build --no-cache app
docker-compose up -d
```

#### Container Crashes on Startup
```powershell
# View detailed logs
docker-compose logs app

# Common causes:
# - Invalid .env file
# - Missing APP_KEY
# - Database not ready (should auto-retry)
```

### Debug Mode

Temporarily enable debugging:
```env
# In .env
APP_DEBUG=true
LOG_LEVEL=debug
```

Then restart:
```powershell
docker-compose restart app
docker-compose logs -f app
```

**Remember**: Set `APP_DEBUG=false` in production!

---

## 🔒 Security Best Practices

### Production Checklist

✅ Set strong passwords:
```env
DB_PASSWORD=use_strong_random_password
DB_ROOT_PASSWORD=different_strong_password
```

✅ Disable debug mode:
```env
APP_DEBUG=false
APP_ENV=production
```

✅ Use HTTPS:
```env
APP_URL=https://yourdomain.com
SESSION_SECURE_COOKIE=true
```

✅ Keep secrets out of version control:
- Never commit `.env` to Git
- Use `.env.example` for templates

✅ Update dependencies regularly:
```powershell
docker-compose exec app composer update
docker-compose exec app npm update
```

✅ Enable firewall rules:
- Only expose necessary ports
- Use reverse proxy for production

---

## 📈 Performance Optimization

### Production Optimizations

```powershell
# Cache configuration
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# Optimize Composer autoloader
docker-compose exec app composer install --optimize-autoloader --no-dev

# Enable OPcache (already configured in docker/php/php.ini)
# opcache.enable=1
# opcache.validate_timestamps=0  # Production only
```

### Scaling Options

**1. Enable Queue Workers** (uncomment in `docker-compose.yml`):
```yaml
queue:
  build: .
  command: php artisan queue:work --tries=3
```

**2. Add Scheduler** (uncomment in `docker-compose.yml`):
```yaml
scheduler:
  build: .
  command: sh -c "while true; do php artisan schedule:run & sleep 60; done"
```

**3. Horizontal Scaling**:
```yaml
app:
  deploy:
    replicas: 3  # Run multiple instances
```

---

## 📚 Additional Resources

- **Full Documentation**: See `DOCKER_DEPLOYMENT_GUIDE.md`
- **Laravel Docs**: https://laravel.com/docs
- **Docker Docs**: https://docs.docker.com
- **Vercel Docs**: https://vercel.com/docs

---

## 🆘 Support

### Logs and Diagnostics

```powershell
# Application logs
docker-compose logs -f app

# Database logs
docker-compose logs db

# All services
docker-compose logs -f

# Export logs
docker-compose logs app > app-logs.txt
```

### Health Check

```powershell
# Check all services
.\docker-manage.ps1 status

# Test health endpoint
curl http://localhost:8080/health

# Container status
docker-compose ps

# Resource usage
docker stats
```

---

## 📝 License

This Docker configuration is part of the Laravel Car Rental System project.

---

**🎉 Your application is ready for deployment!**

For detailed documentation, troubleshooting, and advanced configurations, see `DOCKER_DEPLOYMENT_GUIDE.md`.
