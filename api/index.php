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
];

foreach ($directories as $directory) {
    if (!is_dir($directory)) {
        mkdir($directory, 0755, true);
    }
}

// Set up Laravel for serverless
$_ENV['APP_STORAGE'] = '/tmp/storage';
$_ENV['VIEW_COMPILED_PATH'] = '/tmp/storage/framework/views';

// Bootstrap Laravel application
require __DIR__ . '/../public/index.php';
