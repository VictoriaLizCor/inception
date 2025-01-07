#!/bin/sh

# Load environment variables from .env file
set -a
[ -f .env ] && . ./.env
set +a


# Create secret files
echo "$MYSQL_ROOT_PASSWORD" > secrets/db_root_password.txt
echo "$MYSQL_PASSWORD" > secrets/db_password.txt
echo "$WP_ADMIN_PASSWORD" > secrets/wp_admin_password.txt
echo "$WP_USER_PASSWORD" > secrets/wp_user_password.txt

# Create credentials.txt file
cat <<EOF > secrets/credentials.txt
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_PASSWORD=$MYSQL_PASSWORD
WP_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD
WP_USER_PASSWORD=$WP_USER_PASSWORD
EOF