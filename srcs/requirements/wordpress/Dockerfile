# # filepath: /home/lilizarr/inception/requirements/wordpress/Dockerfile
# FROM wordpress:latest

# # Install mariadb-client
# RUN apt-get update && apt-get install -y mariadb-client

# # Copy any additional configuration or scripts if needed
# # COPY ./conf/wp-config.php /var/www/html/wp-config.php

# # Set the working directory
# WORKDIR /var/www/html
# Stage 1: Build stage
FROM debian:bullseye
# Install necessary packages
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
    php php7.4-fpm php7.4-mysql php7.4-common php7.4-mbstring php7.4-xml php7.4-curl php7.4-gd php7.4-intl php7.4-zip netcat \
    gettext-base sudo openssl curl wget unzip ca-certificates mariadb-client && \
    rm -rf /var/lib/apt/lists/*


# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php var/www/html && \
	chmod -R 777 /var/www/html && \
	chown -R root:root /var/www/ && \
    chown -R www-data:www-data /var/www/html
# # Download and extract WordPress
# RUN wget https://wordpress.org/latest.zip && \
#     unzip latest.zip && \
# 	mkdir -p /var/www/html && \
#     chown -R www-data:www-data /var/www/html && \
#     mv wordpress/* /var/www/html && \
#     rm latest.zip


# Copy PHP-FPM configuration
COPY ./conf/www.cnf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./conf/wp-config.php /wp-config.php.template
COPY ./tools/wp_install.sh /usr/bin/wp_install.sh
RUN chmod +x /usr/bin/wp_install.sh
# Set permissions for wp-content directory
# RUN chmod o+w -R /var/www/html/wp-content
# Install WordPress
# RUN --mount=type=secret,id=credentials \
# 	echo "Running wp_install.sh script" && \
# 	chmod +x /usr/bin/wp_install.sh && \
# 	/usr/bin/wp_install.sh
	

# # Stage 2: Final stage
# FROM debian:bullseye

# # Install necessary packages
# RUN apt-get update -qq && \
#     apt-get install -y -qq --no-install-recommends \
#     php7.4-fpm php7.4-mysql mariadb-client && \
#     rm -rf /var/lib/apt/lists/*


# # Copy the initialized WordPress files from the builder stage
# COPY --from=builder /var/www/html /var/www/html
# COPY --from=builder /etc/php/7.4/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf
# # COPY --from=builder /entrypoint.sh /entrypoint.sh
# RUN chown -R www-data:www-data /var/www/html
RUN find /var/www/html -type d -exec chmod 755 {} \;
RUN find /var/www/html -type f -exec chmod 644 {} \;
# Expose the PHP-FPM port
EXPOSE 9000
WORKDIR /var/www/html
# Start PHP-FPM
# CMD ["php-fpm7.4", "-F"]
CMD ["sh", "-c", "/usr/bin/wp_install.sh"]