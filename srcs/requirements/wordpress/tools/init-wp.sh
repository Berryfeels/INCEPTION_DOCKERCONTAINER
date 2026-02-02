#!/bin/bash

echo "init-wp.sh: Script started."

# Read passwords from secret files
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

echo "init-wp.sh: Secrets loaded."
echo "init-wp.sh: DEBUG - DB_PASSWORD length: ${#DB_PASSWORD}"
echo "init-wp.sh: DEBUG - WP_ADMIN_PASSWORD length: ${#WP_ADMIN_PASSWORD}"
echo "init-wp.sh: DEBUG - WP_USER_PASSWORD length: ${#WP_USER_PASSWORD}"

# Attendi che MariaDB sia pronto
until mysqladmin ping -h mariadb -P 3306 -u ${MARIADB_USER} -p${DB_PASSWORD} --silent; do
    echo "init-wp.sh: Waiting for MariaDB to be ready..."
    sleep 2
done

echo "init-wp.sh: MariaDB is ready."

# Controlla se WordPress è già installato
if [ -f /var/www/html/wp-config.php ]; then
    echo "init-wp.sh: WordPress is already installed. Skipping installation."
else
    echo "init-wp.sh: WordPress not found. Starting installation..."

    # Scarica WP-CLI
    echo "init-wp.sh: Downloading WP-CLI..."
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    echo "init-wp.sh: WP-CLI downloaded."

    # Scarica WordPress
    echo "init-wp.sh: Downloading WordPress core..."
    wp core download --allow-root --path=/var/www/html
    echo "init-wp.sh: WordPress core downloaded."

    # Crea il file di configurazione wp-config.php
    echo "init-wp.sh: Creating wp-config.php..."
    wp config create --allow-root \
        --path=/var/www/html \
        --dbname=${MARIADB_DATABASE} \
        --dbuser=${MARIADB_USER} \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb:3306 \
        --dbprefix=wp_
    echo "init-wp.sh: wp-config.php created."

    # Installa WordPress e crea l'utente amministratore
    echo "init-wp.sh: Installing WordPress core..."
    wp core install --allow-root \
        --path=/var/www/html \
        --url=${DOMAIN_NAME} \
        --title=${WP_TITLE} \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL}
    echo "init-wp.sh: WordPress core installed."

    # Crea un secondo utente
    echo "init-wp.sh: Creating second user..."
    wp user create --allow-root \
        --path=/var/www/html \
        ${WP_USER_LOGIN} \
        ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD}
    echo "init-wp.sh: Second user created."

    # Installa e attiva il plugin Redis
    echo "init-wp.sh: Installing Redis plugin..."
    wp plugin install redis-cache --activate --allow-root --path=/var/www/html
    
    # Configura Redis host prima di abilitare
    wp config set WP_REDIS_HOST redis --allow-root --path=/var/www/html
    wp config set WP_REDIS_PORT 6379 --allow-root --path=/var/www/html
    
    wp redis enable --allow-root --path=/var/www/html
    echo "init-wp.sh: Redis plugin installed."
fi

echo "init-wp.sh: WordPress setup is complete. Starting PHP-FPM..."
# Avvia PHP-FPM in foreground
exec php-fpm8.2 -F
