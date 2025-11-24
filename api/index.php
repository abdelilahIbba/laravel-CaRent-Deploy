<?php

/**
 * Vercel Serverless Function Entry Point for Laravel
 */

// Disable Laravel's bootstrap cache in serverless environment
define('LARAVEL_START', microtime(true));

// Create necessary writable directories
$directories = [
    '/tmp/storage/framework/cache/data',
    '/tmp/storage/framework/sessions',
    '/tmp/storage/framework/views',
    '/tmp/storage/logs',
];

foreach ($directories as $directory) {
    if (!is_dir($directory)) {
        @mkdir($directory, 0755, true);
    }
}

// Set environment variables for serverless
$_ENV['VIEW_COMPILED_PATH'] = '/tmp/storage/framework/views';
$_ENV['APP_SERVICES_CACHE'] = null;  // Disable services cache
$_ENV['APP_PACKAGES_CACHE'] = null;  // Disable packages cache
$_ENV['APP_CONFIG_CACHE'] = null;    // Disable config cache
$_ENV['APP_ROUTES_CACHE'] = null;    // Disable routes cache
$_ENV['APP_EVENTS_CACHE'] = null;    // Disable events cache

// Load the Laravel application
$app = require_once __DIR__ . '/../bootstrap/app.php';

// Handle the request
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);

$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);

$response->send();

$kernel->terminate($request, $response);
