#!/bin/bash

# Start PHP-FPM
php-fpm7.4 --daemonize

# Start Nginx in foreground
echo "Starting Adminer on port 8080..."
exec nginx -g "daemon off;"
