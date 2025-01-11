FROM debian:bullseye as builder

# Install gettext for envsubst and MariaDB server
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends gettext-base mariadb-server sudo openssl passwd && \
    rm -rf /var/lib/apt/lists/*

# Copy the init.sql template and secrets
COPY ./tools/init.sql /init.sql.template

# Set build arguments
ARG MYSQL_DATABASE
ARG MYSQL_USER

# Set environment variables and store them in a temporary file
RUN --mount=type=secret,id=db_root_pass \
    --mount=type=secret,id=db_user_pass \
    export MYSQL_DATABASE=${MYSQL_DATABASE} \
    MYSQL_USER=${MYSQL_USER} \
    MYSQL_PASSWORD=$(cat /run/secrets/db_user_pass) \
    MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_pass) && \
    envsubst < /init.sql.template > /init.sql && cat /init.sql && \
    echo "root:${MYSQL_ROOT_PASSWORD}" | sudo chpasswd && \
    echo "mysql:${MYSQL_PASSWORD}" | sudo chpasswd

# Initialize the MariaDB data directory and run the init.sql script
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
    mysqld_safe --skip-networking & \
    sleep 5 && \
    mysql -uroot < /init.sql && \
    mysqladmin shutdown

# Ensure that all users require a password for login
RUN usermod -s /bin/bash root && usermod -s /bin/bash mysql

# Configure PAM to require a password for the root user
RUN echo "auth required pam_unix.so" >> /etc/pam.d/common-auth 

# # Initialize the MariaDB data directory and run the init.sql script
# RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql && \
#     mysqld_safe --skip-networking & \
#     sleep 5 && \
#     mysql -uroot --skip-password < /init.sql && \
#     mysqladmin shutdown

# Initialize the MariaDB data directory and run the init.sql script


FROM debian:bullseye

# Install MariaDB server and MariaDB client
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends mariadb-server=1:10.5.26-0+deb11u2 mariadb-client=1:10.5.26-0+deb11u2 sudo sudo openssl passwd && \
    apt-get install -y -qq --no-install-recommends curl libaio1 && \
    mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld && \
    rm -rf /var/lib/apt/lists/*

	# Ensure that all users require a password for login
RUN usermod -s /bin/bash root && usermod -s /bin/bash mysql

# Ensure sudo requires a password
RUN echo "root ALL=(ALL) ALL" >> /etc/sudoers

# Configure PAM to require a password for the root user
RUN echo "auth required pam_unix.so" >> /etc/pam.d/common-auth

# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Copy the initialized database from the builder stage
COPY --from=builder /var/lib/mysql /var/lib/mysql

# Only for testing face, TO BE REMOVED
COPY --from=builder /init.sql /init.sql


EXPOSE 3306

USER mysql

# Start MariaDB
# CMD ["sh", "-c", "echo -e '\\033[1;38;2;189;147;249mDatabase is running\\033[m'; exec mysqld_safe"]
CMD ["mysqld_safe"]
