#!/bin/bash
set -e

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Initialize database files if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Check if this is a fresh install (no root password set yet)
# We use a marker file to track initialization
INIT_DONE_MARKER="/var/lib/mysql/.init_done"

if [ ! -f "$INIT_DONE_MARKER" ]; then
    echo "First-time setup required, starting MariaDB temporarily..."
    
    # Start MariaDB temporarily with skip-grant-tables for initial setup
    mysqld --user=mysql --skip-grant-tables --skip-networking &
    TEMP_PID=$!
    
    echo "Waiting for MariaDB to start..."
    until mysqladmin ping --silent 2>/dev/null; do sleep 1; done
    echo "MariaDB started successfully"
    
    echo "Setting up database for the first time..."
    mysql -u root <<SQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
SQL
    
    echo "Database setup complete"
    touch "$INIT_DONE_MARKER"
    
    # Stop the temporary instance
    kill $TEMP_PID
    wait $TEMP_PID 2>/dev/null || true
    echo "Temporary MariaDB instance stopped"
fi

# Start MariaDB in foreground (this is the main process)
echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql
