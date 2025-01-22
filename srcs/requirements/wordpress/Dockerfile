# Stage 1: Build stage
FROM debian:bullseye as builder
COPY ./tools/wp.sh /usr/bin/wp.sh
RUN chmod +x /usr/bin/wp.sh 
RUN --mount=type=secret,id=credentials \
	/usr/bin/wp.sh

# Install necessary packages
FROM debian:bullseye
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
    php php7.4-fpm php7.4-mysql php7.4-common php7.4-mbstring php7.4-xml php7.4-curl php7.4-gd php7.4-intl php7.4-zip netcat sendmail \
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


# Copy PHP-FPM configuration
COPY ./conf/www.cnf /etc/php/7.4/fpm/pool.d/www.conf
COPY ./conf/wp-config.php /wp-config.php.template
COPY ./tools/wp_install.sh /usr/bin/wp_install.sh

RUN chmod +x /usr/bin/wp_install.sh 


RUN find /var/www/html -type d -exec chmod 755 {} \;
RUN find /var/www/html -type f -exec chmod 644 {} \;
COPY --from=builder /credentials /credentials

# Expose the PHP-FPM port
EXPOSE 9000
WORKDIR /var/www/html

CMD ["sh", "-c", "/usr/bin/wp_install.sh"]