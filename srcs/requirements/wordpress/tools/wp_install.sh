#!/bin/bash
# Load secrets
ls /run/secrets/
if [ -f /run/secrets/credentials ]; then
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^# && -n $key ]]; then
            export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
        fi
    done < /run/secrets/credentials
else
    echo "Error: /run/secrets/credentials file not found."
    exit 1
fi

# Substitute environment variables in wp-config.php template
envsubst < /wp-config.php.template > /var/www/html/wp-config.php

## Change to the WordPress directory
cd /var/www/html
echo "Contents of /var/www/html/wp-config.php:"
cat /var/www/html/wp-config.php

# Install WordPress
wp core install --path=/var/www/html --url="$WORDPRESS_URL" --title="$WORDPRESS_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" --skip-email --allow-root

echo "WP was successfully installed"

# Create additional WordPress user if it does not exist
if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
    wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" --role=author --user_pass="$WORDPRESS_USER_PASSWORD" --allow-root
fi