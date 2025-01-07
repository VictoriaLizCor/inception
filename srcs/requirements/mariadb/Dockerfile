FROM debian:bullseye

# Set the locale
RUN apt-get update -qq && apt-get install -y -qq locales apt-utils
RUN locale-gen en_US.UTF-8
RUN locale-gen de_DE.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL=en_US.UTF-8

# Update package lists and upgrade installed packages quietly
RUN apt-get update -qq && apt-get upgrade -y -qq

# Install MariaDB server, MariaDB client, and curl quietly
RUN apt-get install -y -qq mariadb-server mariadb-client curl

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/conf.d/

# Copy initialization script
COPY tools/init.sql /docker-entrypoint-initdb.d/init.sql

RUN echo -e "\e[32mInstallation and setup complete!\e[0m"

CMD ["sh", "-c", "exec mysqld --user=mysql --console --init-file=/docker-entrypoint-initdb.d/init.sql"]