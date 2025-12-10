#!/bin/bash
set -e

if [ -z "$(ls -A /var/www/html)" ]; then
    echo "WordPress not found in /var/www/html - copying now..."
    cp -r /usr/src/wordpress/* /var/www/html/
    chown -R apache:apache /var/www/html
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    
    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
fi

# Ensure permissions are correct
chown -R apache:apache /var/www/html

echo "Starting Apache..."
exec httpd -D FOREGROUND
