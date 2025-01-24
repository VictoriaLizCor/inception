#!/bin/bash
set -x
if [ -f /credentials ]; then
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^# && -n $key ]]; then
            export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
        else
            export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
        fi
    done < /credentials
else
    echo "Error: //credentials file not found."
    exit 1
fi


# env > /credentials
# Load secrets
echo -e "##################################" 
# Ensure TABLE_PREFIX is set

env
# Substitute environment variables in wp-config.php template
# if ! envsubst < /wp-config.php.template > /var/www/html/wp-config.php; then
#     echo "Error: Failed to substitute environment variables in wp-config.php"
#     exit 1
# fi

# wget https://wordpress.org/latest.tar.gz
# tar -xzf latest.tar.D
# cp wordpress/wp-config-sample.php wordpress/wp-config.php
# pwd
## Change to the WordPress directory
cd /var/www/html
# echo "Contents of /var/www/html/wp-config.php:"
# cat /var/www/html/wp-config.php
# Wait for MariaDB to be ready
# echo "Waiting for MariaDB to be ready..."
echo -e "##################################" 
cat /credentials

date
nc -zv mariadb 3306
# mysqladmin -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" status
# mysqladmin ping -h localhost -u"mysql" -p"${MYSQL_PASSWORD}"

echo -e "${MYSQL_HOST}"
mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"
# until mysqladmin ping -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}"; do #--silent; do
#     echo "Waiting for database connection..."
#     sleep 5
# done
# Install WordPress
echo "Downloading WordPress..."
# mv /wordpress/* /var/www/html
# mv wp-config.php wp-config.php.tmp
if wp core is-installed --allow-root; then
    echo "WordPress is already installed."
	wp core update
else
	wp core download --allow-root
	mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
	# echo "Configuring WordPress..."
	wp config set --allow-root DB_NAME "$MYSQL_DATABASE"
	wp config set --allow-root DB_USER "$MYSQL_USER"
	wp config set --allow-root DB_PASSWORD "$MYSQL_PASSWORD"
	wp config set --allow-root DB_HOST "$MYSQL_HOST"
	wp config set --allow-root AUTH_KEY "${AUTH_KEY}"
	wp config set --allow-root SECURE_AUTH_KEY "${SECURE_AUTH_KEY}"
	wp config set --allow-root LOGGED_IN_KEY "${LOGGED_IN_KEY}"
	wp config set --allow-root NONCE_KEY "${NONCE_KEY}"
	wp config set --allow-root AUTH_SALT "${AUTH_SALT}"
	wp config set --allow-root SECURE_AUTH_SALT "${SECURE_AUTH_SALT}"
	wp config set --allow-root LOGGED_IN_SALT "${LOGGED_IN_SALT}"
	wp config set --allow-root NONCE_SALT "${NONCE_SALT}"
fi
# echo -e "################################## first :$WORDPRESS_ADMIN_USER ,  $WORDPRESS_ADMIN_PASSWORD ################################# \n"
# cat wp-config.php
# wp core install --url="https://$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --allow-root
# echo -e "################################## second : $WORDPRESS_USER , $WORDPRESS_USER_PASSWORD  ################################# \n"
# wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" --user_pass="$WORDPRESS_USER_PASSWORD" --role="subscriber" --allow-root


# if wp config create --allow-root --dbhost="$DB_HOST" \
# 	--dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" \
# 	--dbpass=${MYSQL_PASSWORD} ; then
# 	echo "WordPress 'wp-config.php' created successfully"
# else
# 	"Failed to create WordPress 'wp-config.php'"
# fi
# if wp config create --allow-root \
# 	--dbname=${MYSQL_DATABASE} \
# 	--dbuser=${MYSQL_USER} \
# 	--dbpass=${MYSQL_PASSWORD} \
# 	--dbhost=${DB_HOST}:3306 \
#     --dbprefix=${TABLE_PREFIX} \
# 	--dbcharset="utf8mb4"  ; then
# 	echo "WordPress 'wp-config.php' created successfully"
# else
# 	"Failed to create WordPress 'wp-config.php'"
# fi	
echo -e "##################################"
echo "Installing WordPress..."
echo -e "##################################"

if ! wp core install --url="https://$DOMAIN_NAME" --title="$WORDPRESS_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --allow-root; then
    echo "Error: Failed to install WordPress"
    exit 1
fi

echo "WP was successfully installed"
echo -e "##################################"
# Create additional WordPress user if it does not exist
if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
    if ! wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" --user_pass="$WORDPRESS_USER_PASSWORD" --role="subscriber" --allow-root; then
        echo "Error: Failed to create additional WordPress user"
        exit 1
	fi
	# echo "Replacing 'http://example.com' by 'https://example.com' within the WordPress database"
	# wp search-replace "http://example.com" "https://example.com"
	wp option update blog_public 0 --allow-root # Restrict access from search engines
	wp rewrite structure '/%postname%/' --allow-root # Set permalink structure

	# Delete unnecessary plugins and themes
	wp plugin delete hello --allow-root

	if wp theme is-installed twentytwentyfour --allow-root; then
		wp theme delete twentytwentyfour --allow-root
	fi

	# Install necessary plugins
	wp plugin install wp-super-cache --activate --allow-root

fi
echo "WordPress setup completed successfully!"

# Set correct permissions for directories and files
chown www-data:www-data /var/www/html/wp-content/wp-cache-config.php
chmod 664 /var/www/html/wp-content/wp-cache-config.php
find /var/www/html -type d -exec chmod 755 {} \; && \
find /var/www/html -type f -exec chmod 644 {} \;
rm /credentials
php-fpm7.4 -F