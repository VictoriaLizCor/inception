#!/bin/bash
# Load secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_user_pass)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_pass)

# Set environment variables
export MYSQL_DATABASE=${MYSQL_DATABASE}
export MYSQL_USER=${MYSQL_USER}
export MYSQL_PASSWORD=${MYSQL_PASSWORD}
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

# Add error handling
set -e

# Check required environment variables
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "Error: Required environment variables are not set"
    echo "Required variables: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD"
    exit 1
fi

# Set passwords for root and mysql users
echo "Setting passwords for root and mysql users"
echo "root:${MYSQL_ROOT_PASSWORD}" | chpasswd
echo "mysql:${MYSQL_PASSWORD}" | chpasswd 

grep '^root:' /etc/shadow

# Configure PAM to require a password for the root user
echo "auth required pam_unix.so" >> /etc/pam.d/common-auth 

# Configure PAM to require a password for login shells
# echo "auth required pam_unix.so" >> /etc/pam.d/login

# Configure PAM to require a password for su
echo "auth required pam_unix.so" >> /etc/pam.d/su

# Ensure PAM session is properly configured
echo "session required pam_unix.so" >> /etc/pam.d/common-session

# Check and set shell for root user
if [ "$(getent passwd root | cut -d: -f7)" != "/bin/bash" ]; then
    usermod -s /bin/bash root
fi

# Check and set shell for mysql user
if [ "$(getent passwd mysql | cut -d: -f7)" != "/bin/bash" ]; then
    usermod -s /bin/bash mysql
fi

envsubst < /init.sql.template > /init.sql && cat /init.sql

# Perform initialization only if data directory is not initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
else
    echo "MariaDB data directory already initialized."
fi

# Start MariaDB in the background
echo "Starting MariaDB in the background"
service mariadb start
sleep 5

# Check if the database exists
DB_EXISTS=$(mysql -uroot --skip-password -e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';" | grep "${MYSQL_DATABASE}" > /dev/null; echo "$?")

if [ $DB_EXISTS -ne 0 ]; then
    echo "Database ${MYSQL_DATABASE} does not exist. Creating..."
    mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" < /init.sql
    echo "Database ${MYSQL_DATABASE} created."
else
    echo "Database ${MYSQL_DATABASE} already exists."
fi

# Stop MariaDB service
echo "Stopping MariaDB service"
mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "MariaDB initialization completed."