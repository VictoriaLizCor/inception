# Stage 1: Build stage
FROM debian:bullseye as builder

# Install necessary packages
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
    php-fpm php-mysql curl wget unzip && \
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

# Copy PHP-FPM configuration
COPY ./conf/www.cnf /etc/php/7.4/fpm/pool.d/www.conf

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy secrets
COPY ./credentials.txt /run/secrets/credentials

# Configure WordPress
RUN source /run/secrets/credentials && \
    wp config create --path=/var/www/html --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASSWORD --dbhost=$DB_HOST --skip-check && \
    wp config set AUTH_KEY "$AUTH_KEY" && \
    wp config set SECURE_AUTH_KEY "$SECURE_AUTH_KEY" && \
    wp config set LOGGED_IN_KEY "$LOGGED_IN_KEY" && \
    wp config set NONCE_KEY "$NONCE_KEY" && \
    wp config set AUTH_SALT "$AUTH_SALT" && \
    wp config set SECURE_AUTH_SALT "$SECURE_AUTH_SALT" && \
    wp config set LOGGED_IN_SALT "$LOGGED_IN_SALT" && \
    wp config set NONCE_SALT "$NONCE_SALT"

# Stage 2: Final stage
FROM debian:bullseye

# Install necessary packages
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
    php-fpm php-mysql mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Copy the initialized WordPress files from the builder stage
COPY --from=builder /var/www/html /var/www/html
COPY --from=builder /etc/php/7.4/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY --from=builder /entrypoint.sh /entrypoint.sh

# Expose the PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm -F"]