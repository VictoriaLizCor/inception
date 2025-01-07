FROM debian:bullseye

# Set the locale
RUN apt-get update -qq && apt-get install -y -qq locales apt-utils
RUN locale-gen en_US.UTF-8
RUN locale-gen de_DE.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL=en_US.UTF-8

# Install MariaDB server, MariaDB client, and curl quietly if not already installed
RUN dpkg -l | grep -qw mariadb-server || apt-get install -y -qq mariadb-server
RUN dpkg -l | grep -qw mariadb-client || apt-get install -y -qq mariadb-client
RUN dpkg -l | grep -qw curl || apt-get install -y -qq curl

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

# Copy custom MariaDB configuration
COPY ./conf/config.cnf  /etc/mysql/mariadb.conf.d/config.cnf

# Copy initialization script
COPY ./tools/init.sql /docker-entrypoint-initdb.d/init.sql


EXPOSE 3306

RUN echo -e "\e[32mInstallation and setup complete!\e[0m"

CMD ["mysqld_safe"]

