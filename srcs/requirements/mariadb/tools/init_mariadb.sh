#!/bin/bash
# Load secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_user_pass)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_pass)

# Set environment variables
export MYSQL_DATABASE=${MYSQL_DATABASE}
export MYSQL_USER=${MYSQL_USER}
export MYSQL_PASSWORD=${MYSQL_PASSWORD}
export MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}

echo "root:${MYSQL_ROOT_PASSWORD}" | sudo chpasswd
echo "mysql:${MYSQL_PASSWORD}" | sudo chpasswd

envsubst < /init.sql.template > /init.sql && cat /init.sql
# Add error handling
set -e

# Check required environment variables
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo "Error: Required environment variables are not set"
    echo "Required variables: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD"
    exit 1
fi

# Perform initialization only if data directory is not initialized
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB in the background
    mysqld_safe --skip-networking --defaults-file=/etc/mysql/mariadb.conf.d/config.cnf &
    
    # Wait for MariaDB to start
    sleep 10

    # Run the init.sql script
    mysql -uroot < /init.sql
	# Set the root password and flush privileges
    mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"

    # Shutdown MariaDB
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

    echo "MariaDB initialization completed."
else
	echo "MariaDB data directory already initialized."
fi
