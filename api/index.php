<?php

/**
 * Vercel Serverless Function Entry Point for Laravel
 */

// Create necessary directories in /tmp for serverless environment
$directories = [
    '/tmp/storage/framework/cache/data',
    '/tmp/storage/framework/sessions',
    '/tmp/storage/framework/views',
    '/tmp/storage/logs',
    '/tmp/bootstrap/cache',
];

foreach ($directories as $directory) {
    if (!is_dir($directory)) {
        mkdir($directory, 0755, true);
    }
}

// Clear bootstrap cache files to force fresh service provider registration
$cacheFiles = [
    __DIR__ . '/../bootstrap/cache/packages.php',
    __DIR__ . '/../bootstrap/cache/services.php',
    __DIR__ . '/../bootstrap/cache/config.php',
    __DIR__ . '/../bootstrap/cache/routes-v7.php',
    __DIR__ . '/../bootstrap/cache/events.php',
];

foreach ($cacheFiles as $file) {
    if (file_exists($file)) {
        @unlink($file);
    }
}

// Set up Laravel for serverless
$_ENV['APP_STORAGE'] = '/tmp/storage';
$_ENV['VIEW_COMPILED_PATH'] = '/tmp/storage/framework/views';

// Bootstrap Laravel application
require __DIR__ . '/../public/index.php';
