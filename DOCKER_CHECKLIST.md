# ✅ Docker Setup & Deployment Checklist

## Pre-Deployment Checklist

### 1. Prerequisites
- [ ] Docker Desktop installed and running
- [ ] Docker Compose v2.20+ available
- [ ] Git configured
- [ ] Text editor ready (VS Code recommended)

### 2. Initial Configuration
- [ ] Copy `.env.docker` to `.env`
- [ ] Update `APP_KEY` (or will be generated automatically)
- [ ] Change default passwords:
  - [ ] `DB_PASSWORD` (from "secret")
  - [ ] `DB_ROOT_PASSWORD` (from "rootsecret")
- [ ] Set correct `APP_URL` (http://localhost:8080 for Docker)
- [ ] Verify database settings:
  - [ ] `DB_HOST=db` (not 127.0.0.1)
  - [ ] `DB_DATABASE=car_rental_system_db`

### 3. Docker Setup (Choose One)

#### Option A: Automated Setup (Recommended)
- [ ] Run `.\docker-start.ps1`
- [ ] Wait for build to complete (5-10 minutes first time)
- [ ] Verify application opens in browser

#### Option B: Manual Setup
- [ ] Run `docker-compose build`
- [ ] Run `docker-compose up -d`
- [ ] Generate APP_KEY: `docker-compose exec app php artisan key:generate`
- [ ] Run migrations: `docker-compose exec app php artisan migrate`
- [ ] Open http://localhost:8080

### 4. Verification
- [ ] Application loads at http://localhost:8080
- [ ] Database is accessible at localhost:3307
- [ ] Redis is running at localhost:6380
- [ ] Check health endpoint: http://localhost:8080/health
- [ ] Verify logs: `docker-compose logs -f app`
- [ ] Check container status: `docker-compose ps`

---

## Development Workflow Checklist

### Daily Startup
- [ ] Start containers: `.\docker-manage.ps1 start` or `docker-compose up -d`
- [ ] Check status: `.\docker-manage.ps1 status`
- [ ] View logs if needed: `.\docker-manage.ps1 logs`

### Making Code Changes
- [ ] Edit files normally on host machine
- [ ] Changes to PHP/Blade files are immediate (no rebuild)
- [ ] For asset changes (CSS/JS):
  - [ ] Rebuild container: `docker-compose build app`
  - [ ] Restart: `docker-compose up -d`

### Database Changes
- [ ] Create migration: `docker-compose exec app php artisan make:migration`
- [ ] Edit migration file on host
- [ ] Run migration: `.\docker-manage.ps1 migrate`
- [ ] Verify: `docker-compose exec app php artisan migrate:status`

### Adding Dependencies
- [ ] PHP: `docker-compose exec app composer require package/name`
- [ ] NPM: `docker-compose exec app npm install package-name`
- [ ] Rebuild container after composer.json/package.json changes
- [ ] Commit updated lock files

### Daily Shutdown
- [ ] Stop containers: `.\docker-manage.ps1 stop` or `docker-compose down`
- [ ] Data persists automatically

---

## Production Deployment Checklist

### Pre-Production Security
- [ ] `APP_ENV=production` in .env
- [ ] `APP_DEBUG=false` in .env
- [ ] `APP_KEY` is unique and secure
- [ ] Database passwords are strong and unique
- [ ] All sensitive data in .env (not in code)
- [ ] `.env` file is NOT in version control
- [ ] Review `.gitignore` to exclude secrets

### Production Configuration
- [ ] Set correct `APP_URL` (your production domain)
- [ ] Configure production database connection
- [ ] Set up external Redis (if not using container)
- [ ] Configure mail service (SendGrid, Mailgun, etc.)
- [ ] Set up file storage (S3, DigitalOcean Spaces)
- [ ] Configure logging to external service
- [ ] Enable HTTPS/SSL
- [ ] Set `SESSION_SECURE_COOKIE=true`

### Docker Production Build
- [ ] Test build locally: `docker-compose build --no-cache`
- [ ] Verify image size is reasonable (~150-200MB)
- [ ] Test container startup: `docker-compose up -d`
- [ ] Run production optimizations:
  ```powershell
  docker-compose exec app php artisan config:cache
  docker-compose exec app php artisan route:cache
  docker-compose exec app php artisan view:cache
  docker-compose exec app php artisan optimize
  ```
- [ ] Test health endpoint
- [ ] Verify all features work

### Vercel Deployment

#### Setup Phase
- [ ] Install Vercel CLI: `npm install -g vercel`
- [ ] Login: `vercel login`
- [ ] Link project: `vercel link`

#### Database Setup (External Required)
- [ ] Choose database provider:
  - [ ] PlanetScale (MySQL, recommended)
  - [ ] Supabase (PostgreSQL)
  - [ ] AWS RDS
  - [ ] DigitalOcean Managed DB
- [ ] Create database instance
- [ ] Note connection credentials
- [ ] Test connection locally

#### Environment Variables (Vercel Dashboard)
- [ ] `APP_KEY` (base64 encoded)
- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] `APP_URL` (your Vercel domain)
- [ ] `DB_CONNECTION` (mysql or pgsql)
- [ ] `DB_HOST` (external database host)
- [ ] `DB_PORT` (3306 for MySQL, 5432 for PostgreSQL)
- [ ] `DB_DATABASE`
- [ ] `DB_USERNAME`
- [ ] `DB_PASSWORD`
- [ ] `SESSION_DRIVER=cookie` (serverless compatible)
- [ ] `CACHE_STORE=array` (serverless compatible)
- [ ] Mail configuration variables
- [ ] S3 configuration (if using file uploads)

#### File Storage Setup (If Needed)
- [ ] Create S3 bucket (AWS, DigitalOcean, etc.)
- [ ] Configure CORS for bucket
- [ ] Set `FILESYSTEM_DISK=s3`
- [ ] Add AWS credentials to environment variables
- [ ] Test file upload/download

#### Deployment
- [ ] Verify `vercel.json` is configured
- [ ] Run test deployment: `vercel`
- [ ] Test the preview URL
- [ ] Run production deployment: `vercel --prod`
- [ ] Test production URL
- [ ] Verify all features work

#### Post-Deployment
- [ ] Run migrations on production database
- [ ] Seed database if needed
- [ ] Test all critical user flows
- [ ] Monitor error logs
- [ ] Set up uptime monitoring
- [ ] Configure custom domain (if applicable)

---

## Maintenance Checklist

### Weekly Tasks
- [ ] Review application logs
- [ ] Check container health: `.\docker-manage.ps1 status`
- [ ] Monitor disk space: `docker system df`
- [ ] Backup database: `.\docker-manage.ps1 backup`

### Monthly Tasks
- [ ] Update dependencies:
  ```powershell
  docker-compose exec app composer update
  docker-compose exec app npm update
  ```
- [ ] Rebuild containers: `.\docker-manage.ps1 rebuild`
- [ ] Review security updates
- [ ] Test backup restoration
- [ ] Clean up old Docker images: `docker image prune -a`

### As Needed
- [ ] Scale containers if traffic increases
- [ ] Optimize database queries
- [ ] Review and optimize caching
- [ ] Update Laravel framework
- [ ] Security patches

---

## Troubleshooting Checklist

### Container Won't Start
- [ ] Check logs: `docker-compose logs app`
- [ ] Verify .env file exists and is valid
- [ ] Check for port conflicts
- [ ] Ensure Docker Desktop is running
- [ ] Try rebuild: `docker-compose build --no-cache`

### Database Connection Issues
- [ ] Verify `DB_HOST=db` (in Docker)
- [ ] Check DB container is running: `docker-compose ps db`
- [ ] View DB logs: `docker-compose logs db`
- [ ] Test connection: `docker-compose exec app php artisan db:show`
- [ ] Verify credentials in .env

### Permission Errors
- [ ] Fix storage permissions:
  ```powershell
  docker-compose exec app chown -R www-data:www-data /var/www/html/storage
  docker-compose exec app chmod -R 775 /var/www/html/storage
  ```
- [ ] Fix bootstrap cache:
  ```powershell
  docker-compose exec app chown -R www-data:www-data /var/www/html/bootstrap/cache
  docker-compose exec app chmod -R 775 /var/www/html/bootstrap/cache
  ```

### Assets Not Loading
- [ ] Rebuild container: `docker-compose build --no-cache app`
- [ ] Clear Laravel cache: `docker-compose exec app php artisan cache:clear`
- [ ] Check Nginx logs: `docker-compose logs app | Select-String nginx`
- [ ] Verify build directory exists: `ls public/build`

### Performance Issues
- [ ] Check resource usage: `docker stats`
- [ ] Enable all caches:
  ```powershell
  docker-compose exec app php artisan optimize
  ```
- [ ] Verify OPcache is enabled
- [ ] Review slow query logs
- [ ] Consider scaling Redis

### Complete Reset (Nuclear Option)
- [ ] ⚠️ **WARNING: This deletes ALL data**
- [ ] Stop containers: `docker-compose down`
- [ ] Remove volumes: `docker-compose down -v`
- [ ] Remove images: `docker-compose down --rmi all -v`
- [ ] Clean system: `docker system prune -a --volumes`
- [ ] Rebuild: `docker-compose build --no-cache`
- [ ] Start fresh: `docker-compose up -d`

---

## Documentation Reference

Quick links to documentation files:

- [ ] **Quick Start**: `DOCKER_README.md` (10 min read)
- [ ] **Full Guide**: `DOCKER_DEPLOYMENT_GUIDE.md` (30 min read)
- [ ] **Commands**: `DOCKER_QUICK_REF.md` (reference)
- [ ] **Architecture**: `DOCKER_ARCHITECTURE.md` (diagrams)
- [ ] **Summary**: `DOCKER_SETUP_SUMMARY.md` (overview)
- [ ] **This File**: `DOCKER_CHECKLIST.md` (you are here)

---

## Common Commands Quick Reference

```powershell
# Start
.\docker-manage.ps1 start

# Stop
.\docker-manage.ps1 stop

# Logs
.\docker-manage.ps1 logs

# Status
.\docker-manage.ps1 status

# Migrate
.\docker-manage.ps1 migrate

# Shell
.\docker-manage.ps1 shell

# Backup
.\docker-manage.ps1 backup

# Help
.\docker-manage.ps1 help
```

---

## Emergency Contacts & Resources

- **Docker Documentation**: https://docs.docker.com
- **Laravel Documentation**: https://laravel.com/docs
- **Vercel Documentation**: https://vercel.com/docs
- **Project Issues**: [Your GitHub Issues URL]

---

**Last Updated**: [Date]
**Version**: 1.0.0

**Status**: 
- [ ] In Development
- [ ] Testing
- [ ] Staging
- [ ] Production

**Notes**:
_Use this section for project-specific notes_

---

**Remember**: Always test in development before deploying to production!
