FROM debian:bullseye as builder

# Install gettext for envsubst and MariaDB server
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends gettext-base mariadb-server sudo openssl passwd && \
    rm -rf /var/lib/apt/lists/*

# Copy the init.sql template and secrets
COPY ./tools/init.sql /init.sql.template
COPY ./tools/init_mariadb.sh /init_mariadb.sh
# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Set build arguments
ARG MYSQL_DATABASE
ARG MYSQL_USER

# Set environment variables and store them in a temporary file
RUN --mount=type=secret,id=db_root_pass \
    --mount=type=secret,id=db_user_pass \
    echo "Running init_mariadb.sh script" && \
    chmod +x /init_mariadb.sh && \
    /init_mariadb.sh

# Ensure that all users require a password for login
RUN usermod -s /bin/bash root && usermod -s /bin/bash mysql

# Configure PAM to require a password for the root user
RUN echo "auth required pam_unix.so" >> /etc/pam.d/common-auth 

FROM debian:bullseye

# Install MariaDB server and MariaDB client
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends mariadb-server=1:10.5.26-0+deb11u2 mariadb-client=1:10.5.26-0+deb11u2 sudo sudo openssl passwd && \
    apt-get install -y -qq --no-install-recommends curl libaio1 && \
    mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql && \
    rm -rf /var/lib/apt/lists/*

# Ensure that all users require a password for login
RUN usermod -s /bin/bash root && usermod -s /bin/bash mysql

# Ensure sudo requires a password
COPY --from=builder /etc/sudoers /etc/sudoers

# Configure PAM to require a password for the root user
COPY --from=builder /etc/pam.d/common-auth /etc/pam.d/common-auth

# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Copy the initialized database from the builder stage
COPY --from=builder /var/lib/mysql /var/lib/mysql

# Ensure the /run/mysqld and /var/log/mysql directories exist and have the correct permissions
RUN mkdir -p /run/mysqld /var/log/mysql && chown -R mysql:mysql /run/mysqld /var/log/mysql /var/lib/mysql

# Only for testing phase, TO BE REMOVED
COPY --from=builder /init.sql /init.sql

EXPOSE 3306

USER mysql

# Start MariaDB with the specified configuration file
CMD ["mysqld_safe", "--defaults-file=/etc/mysql/mariadb.conf.d/config.cnf", "--datadir=/var/lib/mysql", "--user=mysql"]