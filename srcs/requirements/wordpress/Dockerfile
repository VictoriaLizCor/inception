# Use Debian Bullseye as the base image for the builder stage
FROM debian:bullseye as builder

# Install necessary packages
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends sudo openssl \
    ca-certificates passwd gettext-base curl wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Download and extract WordPress
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    mv wordpress /var/www/html && \
    rm latest.zip

# Copy necessary files
COPY ./tools/wp-config.php /var/www/html/wp-config.php

# Set permissions for WordPress directories
RUN chown -R www-data:www-data /var/www/html

# Final stage
FROM debian:bullseye

# Install necessary packages
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends sudo openssl \
    ca-certificates passwd curl libaio1 libpam0g apache2 php php-mysql && \
    rm -rf /var/lib/apt/lists/*

# Copy the initialized WordPress files from the builder stage
COPY --from=builder /var/www/html /var/www/html
COPY --from=builder /usr/local/bin/wp /usr/local/bin/wp

# Set environment variables
ENV WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST}
ENV WORDPRESS_DB_USER=${WORDPRESS_DB_USER}
ENV WORDPRESS_DB_PASSWORD=${WORDPRESS_DB_PASSWORD}
ENV WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME}
ENV WORDPRESS_TABLE_PREFIX=${WP_TABLE_PREFIX:-wp_}
ENV WORDPRESS_DEBUG=${WP_DEBUG:-0}

# Use secrets for sensitive information
RUN --mount=type=secret,id=wp_admin_pass \
    --mount=type=secret,id=wp_user_pass \
    echo "Secrets loaded"

# Expose the WordPress port
EXPOSE 9000

# Start Apache
CMD ["apache2-foreground"]


RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-soap \
    php-xml \
    php-xmlrpc \
    php-zip \
    wget \
    mariadb-client \
    vim 

RUN mkdir -p /run/php
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# COPY ./conf/wp-config.php /var/www/html

COPY ./conf/www.conf /etc/php/7.3/fpm/pool.d/
COPY ./tools/setup.sh ./

RUN chmod +x /setup.sh

# EXPOSE  9000

ENTRYPOINT [ "sh", "/setup.sh" ]