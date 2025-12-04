# Use only for development and testing purposes, not for production deployments.
# This Dockerfile sets up a MariaDB server on a Debian Trixie base image.
FROM alpine:3.23.0

# Install MariaDB and client
RUN apk add --no-cache mariadb mariadb-client mariadb-server-utils bash

# Enable networking
RUN sed -i 's/skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf

# Create directories and set permissions
RUN mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld \
    && chmod 777 /run/mysqld

# Copy entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["entrypoint.sh"]


