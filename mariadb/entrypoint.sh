#!/bin/bash
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    echo "Starting temporary server..."
    mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"

    sleep 10

    echo "Setting up users..."
    mysql -u root <<-EOSQL
        FLUSH PRIVILEGES;
        ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PASSWORD}');
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "Stopping temporary server..."
    if ! mysqladmin shutdown -u root --password="${MYSQL_ROOT_PASSWORD}"; then
        echo "mysqladmin shutdown failed, trying kill..."
        kill "$pid"
    fi
    
    wait "$pid"
fi

echo "Starting MariaDB..."
exec mariadbd --bind-address=0.0.0.0 --user=mysql
