FROM debian:bullseye as builder

# Install gettext for envsubst and MariaDB server
RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends sudo openssl \
    ca-certificates passwd gettext-base curl libaio1 libpam0g && \
    curl -L -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup -o mariadb_repo_setup && \
    chmod +x mariadb_repo_setup && \
    ./mariadb_repo_setup --mariadb-server-version=10.5 && \
    apt-get update && apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy necessary files
COPY ./tools/init.sql /init.sql.template
COPY ./tools/init_mariadb.sh /usr/bin/init_mariadb.sh
# COPY ./tools/login /etc/pam.d/login
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf
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

RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends sudo openssl \
    ca-certificates passwd curl libaio1 libpam0g netcat && \
    curl -L -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup -o mariadb_repo_setup && \
    chmod +x mariadb_repo_setup && \
    ./mariadb_repo_setup --mariadb-server-version=10.5 && \
    apt-get update && apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql

#  Copy the initialized database and necessary files from the builder stage
COPY --from=builder /var/lib/mysql /var/lib/mysql
# COPY --from=builder /etc/pam.d/login /etc/pam.d/login
COPY --from=builder /etc/mysql/mariadb.conf.d/config.cnf /etc/mysql/mariadb.conf.d/config.cnf
COPY --from=builder /usr/local/bin/pass_request.sh /usr/local/bin/pass_request.sh
# COPY --from=builder /etc/sudoers /etc/sudoers
# COPY --from=builder /etc/passwd /etc/passwd
# COPY --from=builder /etc/group /etc/group
# COPY --from=builder /etc/shadow /etc/shadow
# COPY --from=builder /etc/pam.d/ /etc/pam.d/

# Make the entrypoint script executable and configure login
RUN chmod +x /usr/local/bin/pass_request.sh && \
echo 'source /usr/local/bin/pass_request.sh' >> /etc/bash.bashrc && \
chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql


EXPOSE 3306

USER mysql

# Start MariaDB with the specified configuration file
CMD ["mysqld_safe", "--defaults-file=/etc/mysql/mariadb.conf.d/config.cnf", "--datadir=/var/lib/mysql", "--user=mysql"]
