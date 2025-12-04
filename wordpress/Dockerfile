FROM alpine:3.23.0

# Where your app (WordPress/phpMyAdmin) will live
ENV APP_ROOT=/var/www/html

# Install Apache + PHP 8.5 and common extensions for WordPress/phpMyAdmin
RUN apk add --no-cache \
    apache2 \
    apache2-utils \
    php85 \
    php85-apache2 \
    php85-mysqli \
    php85-json \
    php85-openssl \
    php85-curl \
    php85-zlib \
    php85-xml \
    php85-mbstring \
    php85-session \
    php85-iconv \
    php85-ctype \
    php85-gd \
    php85-zip \
    php85-dom \
    php85-xmlreader \
    php85-exif \
    php85-fileinfo \
    php85-pecl-imagick \
    php85-intl \
    bash \
    curl \
    ca-certificates \
    openssl

# Create application directory and adjust Apache DocumentRoot
RUN mkdir -p ${APP_ROOT} \
    && chown -R apache:apache ${APP_ROOT}

# Enable mod_rewrite and set some sane defaults in httpd.conf
RUN sed -i 's|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|' /etc/apache2/httpd.conf \
    && sed -i 's|^#ServerName www.example.com:80|ServerName localhost:80|' /etc/apache2/httpd.conf \
    && sed -i 's|^DocumentRoot ".*"|DocumentRoot "/var/www/html"|' /etc/apache2/httpd.conf \
    && sed -i 's|^<Directory ".*">|<Directory "/var/www/html">|' /etc/apache2/httpd.conf \
    && sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/httpd.conf \
    && sed -i 's|Options Indexes FollowSymLinks|Options FollowSymLinks|g' /etc/apache2/httpd.conf

# Optional: extra vhost config tailored for WordPress-style rewrites
RUN cat <<'EOF' > /etc/apache2/conf.d/wordpress.conf
<VirtualHost *:80>
    ServerName localhost

    DocumentRoot "/var/www/html"

    <Directory "/var/www/html">
        AllowOverride All
        Options FollowSymLinks
        Require all granted

        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteBase /
            RewriteRule ^index\.php$ - [L]
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule . /index.php [L]
        </IfModule>
    </Directory>

    ErrorLog  /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

# Ensure log dir exists
RUN mkdir -p /var/log/apache2 \
    && chown -R apache:apache /var/log/apache2

# Download and extract WordPress
RUN mkdir -p /usr/src/wordpress \
    && curl -L -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 \
    && rm /tmp/wordpress.tar.gz \
    && chown -R apache:apache /usr/src/wordpress

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Switch to apache user for security
# USER apache

WORKDIR ${APP_ROOT}

# You will mount your app here:
# - For WordPress: mount wordpress files into /var/www/html
# - For phpMyAdmin: mount phpMyAdmin files into /var/www/html

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]

# Healthcheck (simple HTTP check)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -fsS http://127.0.0.1/ >/dev/null || exit 1

# Start Apache in foreground (required for Docker)
CMD ["httpd", "-D", "FOREGROUND"]
