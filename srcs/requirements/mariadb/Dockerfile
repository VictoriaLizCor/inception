FROM debian:bullseye as builder

# Set build arguments
ARG MYSQL_DATABASE
ARG MYSQL_USER
# ARG MARIADB_USER
# ARG MARIADB_PASSWORD

# Install gettext for envsubst and MariaDB server
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends gettext-base mariadb-server sudo && \
    rm -rf /var/lib/apt/lists/*

# Set the root user's shell to /bin/bash to enable password prompt
RUN usermod -s /bin/bash root

# Copy the init.sql template and secrets
COPY ./tools/init.sql /init.sql.template

# Replace placeholders in init.sql using envsubst
RUN --mount=type=secret,id=db_root_pass \
    --mount=type=secret,id=db_user_pass \

    export MYSQL_PASSWORD=$(cat /run/secrets/db_user_pass) \
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_pass) && \
	MYSQL_DATABASE=${MYSQL_DATABASE} \
    MYSQL_USER=${MYSQL_USER} \
    envsubst < /init.sql.template > /init.sql

RUN    echo "root:${MYSQL_ROOT_PASSWORD}" | chpasswd

# # Initialize the MariaDB data directory and run the init.sql script
# RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
#     mysqld_safe --skip-networking & \
#     sleep 5 && \
#     mysql -uroot --skip-password < /init.sql && \
#     mysqladmin shutdown

# Initialize the MariaDB data directory and run the init.sql script
RUN rm -rf /var/lib/mysql/* && \
    mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    mysqld_safe --skip-networking & \
    sleep 5 && \
    if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then \
        echo "Initializing database..."; \
        mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" < /init.sql; \
        mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown; \
    else \
        echo "Database already initialized"; \
    fi

FROM debian:bullseye

# Install MariaDB server and MariaDB client
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends mariadb-server=1:10.5.26-0+deb11u2 mariadb-client=1:10.5.26-0+deb11u2 sudo && \
    apt-get install -y -qq --no-install-recommends curl libaio1 && \
    mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld && \
    rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Copy the initialized database from the builder stage
COPY --from=builder /var/lib/mysql /var/lib/mysql
# Only for testing face, TO BE REMOVED
COPY --from=builder /init.sql /init.sql

# Set the root user's shell to /sbin/nologin to  root login
RUN usermod -s /bin/bash root

# Ensure sudo requires a password
RUN echo "root ALL=(ALL) ALL" >> /etc/sudoers

EXPOSE 3306

USER mysql

# Start MariaDB
# CMD ["sh", "-c", "echo -e '\\033[1;38;2;189;147;249mDatabase is running\\033[m'; exec mysqld_safe"]
CMD ["mysqld_safe"]
