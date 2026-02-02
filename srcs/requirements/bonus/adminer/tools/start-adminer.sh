#!/bin/bash

# Start PHP-FPM in background (helper process, not main)
php-fpm8.2

# Start Nginx in foreground (main process)
echo "Starting Adminer on port 8080..."
echo "https://${DOMAIN_NAME}:8080/?server=${MARIADB_SERVER}&username=${MARIADB_USER}&database=${MARIADB_DATABASE}"
exec nginx -g "daemon off;"
