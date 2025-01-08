FROM debian:bullseye

# Install MariaDB server, MariaDB client, and curl quietly
RUN apt-get update -qq && \
	apt-get install -y -qq mariadb-server mariadb-client curl && \
	mkdir -p /var/lib/mysql /run/mysqld /run/secrets && \
	chown -R mysql:mysql /var/lib/mysql /run/mysqld /run/secrets
 
	# if ! getent group mysql > /dev/null; then groupadd -r mysql; fi && \
	# if ! getent passwd mysql > /dev/null; then useradd -r -g mysql mysql; fi && \

# Copy custom MariaDB configuration
COPY ./conf/config.cnf /etc/mysql/mariadb.conf.d/config.cnf
COPY ./tools/init.sql /docker-entrypoint-initdb.d/init.sql

# Initialize the MariaDB data directory
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

EXPOSE 3306

USER mysql

CMD ["mysqld_safe"]
# CMD ["mysqld_safe", "--init-file=/docker-entrypoint-initdb.d/init_db.sql"]
