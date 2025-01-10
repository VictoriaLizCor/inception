# syntax=docker/dockerfile:1.2

FROM debian:bullseye as builder

# Install gettext for envsubst and MariaDB server
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends gettext-base mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy the init.sql template and secrets
COPY ./tools/init.sql /init.sql.template

# Set build arguments
ARG MYSQL_DATABASE
ARG MYSQL_USER

# Replace placeholders in init.sql using envsubst
RUN --mount=type=secret,id=db_root_pass \
    --mount=type=secret,id=db_user_pass \
    export MYSQL_DATABASE=${MYSQL_DATABASE} \
    MYSQL_USER=${MYSQL_USER} \
    MYSQL_PASSWORD=$(cat /run/secrets/db_user_pass) \
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_pass) && \
    envsubst < /init.sql.template > /init.sql && cat /init.sql

# Initialize the MariaDB data directory and run the init.sql script
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    mysqld_safe --skip-networking & \
    sleep 5 && \
    mysql -uroot < /init.sql && \
    mysqladmin shutdown

FROM debian:bullseye

# Install MariaDB server and MariaDB client
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends mariadb-server=1:10.5.26-0+deb11u2 mariadb-client=1:10.5.26-0+deb11u2 && \
    apt-get install -y -qq --no-install-recommends curl libaio1 && \
    mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld && \
    rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Copy the initialized database from the builder stage
COPY --from=builder /var/lib/mysql /var/lib/mysql

EXPOSE 3306

USER mysql

# Start MariaDB
# CMD ["sh", "-c", "echo -e '\\033[1;38;2;189;147;249mDatabase is running\\033[m'; exec mysqld_safe"]
CMD ["mysqld_safe"]
