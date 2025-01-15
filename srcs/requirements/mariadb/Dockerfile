FROM debian:bullseye as builder

# Install gettext for envsubst and MariaDB server
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends gettext-base mariadb-server && \
    apt-get install -y -qq --no-install-recommends sudo openssl passwd curl libaio1 libpam0g && \
    rm -rf /var/lib/apt/lists/*

# Copy the init.sql template and secrets
COPY ./tools/init.sql /init.sql.template
COPY ./tools/init_mariadb.sh /usr/bin/init_mariadb.sh

# Copy login config
COPY ./tools/login /etc/pam.d/login
# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Copy the pass script 
COPY ./tools/pass_request.sh /usr/local/bin/pass_request.sh 

# Set build arguments
ARG MYSQL_DATABASE
ARG MYSQL_USER

# Set environment variables and store them in a temporary file
RUN --mount=type=secret,id=db_root_pass \
    --mount=type=secret,id=db_user_pass \
    echo "Running init_mariadb.sh script" && \
    chmod +x /usr/bin/init_mariadb.sh && \
    /usr/bin/init_mariadb.sh

FROM debian:bullseye

# Install MariaDB server and MariaDB client
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends mariadb-server=1:10.5.26-0+deb11u2 mariadb-client=1:10.5.26-0+deb11u2

# Install additional dependencies
RUN apt-get install -y -qq --no-install-recommends sudo openssl passwd curl libaio1 libpam0g && \
    mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && \
    rm -rf /var/lib/apt/lists/*

# Copy the initialized database from the builder stage
COPY --from=builder /var/lib/mysql /var/lib/mysql
COPY --from=builder /etc/pam.d/login /etc/pam.d/login
COPY --from=builder /etc/mysql/mariadb.conf.d/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Make the entrypoint script executable
COPY --from=builder /usr/local/bin/pass_request.sh /usr/local/bin/pass_request.sh
# Copy necessary files from the build stage to the final stage 
COPY --from=builder /etc/sudoers /etc/sudoers 
COPY --from=builder /etc/passwd /etc/passwd 
COPY --from=builder /etc/group /etc/group
COPY --from=builder /etc/shadow /etc/shadow
COPY --from=builder /etc/pam.d/ /etc/pam.d/

# Make the entrypoint script executable and configure login
RUN chmod +x /usr/local/bin/pass_request.sh 
# Configure PAM authentication for bash sessions 

RUN echo "mysql:lilizarr123" | chpasswd
RUN echo "root:root42" | chpasswd
# RUN echo 'function secure_bash() { /usr/local/bin/pass_request.sh; }' >> /etc/bash.bashr
# RUN echo 'source /usr/local/bin/pass_request.sh' >> /etc/bash.bashrc

# Set permissions for MariaDB directories
RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql

EXPOSE 3306

USER mysql

# Start MariaDB with the specified configuration file
CMD ["mysqld_safe", "--defaults-file=/etc/mysql/mariadb.conf.d/config.cnf", "--datadir=/var/lib/mysql", "--user=mysql"]
