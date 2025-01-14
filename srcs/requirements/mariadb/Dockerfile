FROM debian:bullseye as builder

# Install gettext for envsubst and MariaDB server
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends gettext-base mariadb-server && \
	apt-get install -y -qq --no-install-recommends sudo openssl passwd curl libaio1 libpam0g && \
    rm -rf /var/lib/apt/lists/*

# Copy the init.sql template and secrets
COPY ./tools/init.sql /init.sql.template
COPY ./tools/init_mariadb.sh /usr/bin/init_mariadb.sh

# copy login config
COPY ./tools/login /etc/pam.d/login
# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf
# Copy the entrypoint script 
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
#The `libaio1` package provides the Linux kernel asynchronous I/O (AIO) access library, which can improve the performance of database systems like MariaDB by allowing them to handle I/O operations more efficiently.

# Ensure that all users require a password for login
RUN if [ "$(getent passwd root | cut -d: -f7)" != "/bin/bash" ]; then usermod -s /bin/bash root; fi && \
    if [ "$(getent passwd mysql | cut -d: -f7)" != "/bin/bash" ]; then usermod -s /bin/bash mysql; fi

# # Configure SSH to require password authentication
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#     sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config


# Ensure sudo requires a password
RUN echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers

# Configure PAM to require a password for all users
RUN echo "auth required pam_unix.so" >> /etc/pam.d/common-auth

# Configure PAM to require a password for login shells
# RUN echo "auth       required   pam_unix.so try_first_pass nullok_secure pwfeedback" >> /etc/pam.d/login

# Configure PAM to require a password for su
RUN echo "auth required pam_unix.so" >> /etc/pam.d/su
RUN echo "account required pam_unix.so" >> /etc/pam.d/su
RUN echo "session required pam_unix.so" >> /etc/pam.d/su
# Ensure PAM session is properly configured
RUN echo "session required pam_unix.so" >> /etc/pam.d/common-session

# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf

# Copy the initialized database from the builder stage
COPY --from=builder /var/lib/mysql /var/lib/mysql
COPY --from=builder /etc/pam.d/login /etc/pam.d/login
COPY --from=builder /etc/shadow  /etc/shadow

RUN chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql
# Only for testing phase, TO BE REMOVED
COPY --from=builder /init.sql /init.sql

# Make the entrypoint script executable
COPY --from=builder /usr/local/bin/pass_request.sh /usr/local/bin/pass_request.sh
RUN chmod +x /usr/local/bin/pass_request.sh 
# Set the entrypoint ENTRYPOINT
RUN echo 'function secure_bash() { /usr/local/bin/pass_request.sh; }' >> /root/.bashrc && source 

EXPOSE 3306

USER mysql

# Start MariaDB with the specified configuration file
CMD ["mysqld_safe", "--defaults-file=/etc/mysql/mariadb.conf.d/config.cnf", "--datadir=/var/lib/mysql", "--user=mysql"]