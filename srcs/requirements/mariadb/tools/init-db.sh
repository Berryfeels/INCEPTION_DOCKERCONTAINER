#!/bin/bash

# Initialize MySQL if data directory is empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in background
mysqld --user=mysql &
MYSQL_PID=$!

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
while ! mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB started successfully"

# Read passwords from secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

# Secure the installation and create databases/users
mysql -u root << EOF
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove remote root login (except for necessary connections)
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create WordPress database
CREATE DATABASE IF NOT EXISTS wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Create WordPress user (regular user)
CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';

-- Create WordPress admin user (admin user, but not with forbidden names)
CREATE USER IF NOT EXISTS 'wpmanager'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpmanager'@'%';

-- Flush privileges
FLUSH PRIVILEGES;
EOF

echo "Database and users created successfully"

# Stop background MariaDB
kill $MYSQL_PID
wait $MYSQL_PID

echo "Starting MariaDB in foreground..."
# Start MariaDB in foreground
exec mysqld --user=mysql
