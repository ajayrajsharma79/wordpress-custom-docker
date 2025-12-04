#!/bin/bash
set -e

if [ -z "$(ls -A /var/www/html)" ]; then
    echo "phpMyAdmin not found in /var/www/html - copying now..."
    cp -r /usr/src/phpmyadmin/* /var/www/html/
    chown -R apache:apache /var/www/html
fi

# Configure phpMyAdmin to connect to the database
if [ ! -f /var/www/html/config.inc.php ]; then
    cp /var/www/html/config.sample.inc.php /var/www/html/config.inc.php
    sed -i "s/localhost/$PHPMYADMIN_HOST/" /var/www/html/config.inc.php
    # Generate a random blowfish secret
    SECRET=$(openssl rand -base64 32)
    sed -i "s|\$cfg\['blowfish_secret'\] = '';|\$cfg['blowfish_secret'] = '$SECRET';|" /var/www/html/config.inc.php
fi

echo "Starting Apache..."
exec httpd -D FOREGROUND
