#!/bin/sh
# Docker entrypoint script for Laravel
# Handles initialization tasks before starting the application

set -e

echo "🚀 Starting Laravel application initialization..."

# Wait for database to be ready
echo "⏳ Waiting for database connection..."
until php artisan db:show 2>/dev/null; do
    echo "Database not ready, waiting 2 seconds..."
    sleep 2
done
echo "✅ Database connection established"

# Clear and cache configuration for production
echo "🔧 Optimizing Laravel caches..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run database migrations
echo "📦 Running database migrations..."
php artisan migrate --force --no-interaction

# Create storage link if it doesn't exist
if [ ! -L /var/www/html/public/storage ]; then
    echo "🔗 Creating storage symlink..."
    php artisan storage:link
fi

# Set permissions (edge case: if mounted volumes override permissions)
echo "🔐 Setting proper permissions..."
chown -R www-data:www-data /var/www/html/storage
chown -R www-data:www-data /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage
chmod -R 775 /var/www/html/bootstrap/cache

echo "✅ Initialization complete! Starting application services..."

# Execute the main command (supervisor)
exec "$@"
