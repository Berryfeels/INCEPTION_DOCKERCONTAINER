FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y php php-fpm php-mysql nginx wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN mkdir -p /var/www/html && \
    wget -O /var/www/html/index.php https://www.adminer.org/latest.php

# Copy configurations
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/start-adminer.sh /usr/local/bin/start-adminer.sh

RUN chmod +x /usr/local/bin/start-adminer.sh && \
    chown -R www-data:www-data /var/www/html

# Configure PHP-FPM
RUN sed -i 's|listen = /run/php/php.*-fpm.sock|listen = 0.0.0.0:9000|g' /etc/php/*/fpm/pool.d/www.conf && \
    mkdir -p /run/php

EXPOSE 8080

CMD ["/usr/local/bin/start-adminer.sh"]
