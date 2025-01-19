#!/bin/bash

# Load secrets
if [ -f /run/secrets/credentials ]; then
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^# && -n $key ]]; then
            export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
		else
			export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
        fi
    done < /run/secrets/credentials
else
    echo "Error: /run/secrets/credentials file not found."
    exit 1
fi
# Ensure TABLE_PREFIX is set
export TABLE_PREFIX=${TABLE_PREFIX:-wp_}

env
# Substitute environment variables in wp-config.php template
# if ! envsubst < /wp-config.php.template > /var/www/html/wp-config.php; then
#     echo "Error: Failed to substitute environment variables in wp-config.php"
#     exit 1
# fi

## Change to the WordPress directory
cd /var/www/html
echo "Contents of /var/www/html/wp-config.php:"
# cat /var/www/html/wp-config.php
# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
mysqladmin -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" status

# mysqladmin ping -h"${DB_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}"
# until mysqladmin ping -h"${DB_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}"; do #--silent; do
#     echo "Waiting for database connection..."
#     sleep 5
# done
# Install WordPress
wp core download --allow-root
echo "Downloading WordPress..."
wp core download --allow-root

echo "Configuring WordPress..."
# mv /var/www/html/wp-config.php /var/www/html/wp-config.php.bak
if wp config create --allow-root --dbhost="$DB_HOST" \
	--dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" \
	--dbpass=${MYSQL_PASSWORD} ; then
	echo "WordPress 'wp-config.php' created successfully"
else
	echoTo github.com:VictoriaLizCor/inception.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'github.com:VictoriaLizCor/inception.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
 git push failed, setting upstream branch 
To github.com:VictoriaLizCor/inception.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to 'github.com:VictoriaLizCor/inception.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
 git push --set-upstream failed with error 
make: *** [tools.mk:27: gPush] Error 1

 "Failed to create WordPress 'wp-config.php'"
fi
# wp config create --allow-root \
# 	--dbname=${MYSQL_DATABASE} \
# 	--dbuser=${MYSQL_USER} \
# 	--dbpass=${MYSQL_PASSWORD} \
# 	--dbhost=${DB_HOST} \
# 	--dbcharset="utf8mb4"

echo "Installing WordPress..."
wp core install --allow-root \
	--url=https://${DOMAIN_NAME} \
	--title="WordPress Site" \
	--admin_user=${WORDPRESS_ADMIN_USER} \
	--admin_password=${WORDPRESS_ADMIN_PASSWORD} \
	--admin_email=${WORDPRESS_ADMIN_EMAIL}
# if ! wp core install --path=/var/www/html --url="$WORDPRESS_URL" --title="$WORDPRESS_TITLE" \
#     --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
#     --admin_email="$WORDPRESS_ADMIN_EMAIL" --skip-email --allow-root; then
#     echo "Error: Failed to install WordPress"
#     exit 1
# fi

echo "WP was successfully installed"

# Create additional WordPress user if it does not exist
if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
    if ! wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" --role=author --user_pass="$WORDPRESS_USER_PASSWORD" --allow-root; then
        echo "Error: Failed to create additional WordPress user"
        exit 1
    else
        wp option update blog_public 0 --allow-root # Restrict access from search engines
        wp rewrite structure '/%postname%/' --allow-root # Set permalink structure

        # Delete unnecessary plugins and themes
        wp plugin delete hello --allow-root
        wp theme delete twentynineteen twentytwenty --allow-root

        # Install necessary plugins
        wp plugin install wp-super-cache --activate --allow-root

        echo "WordPress setup completed successfully!"
    fi
fi