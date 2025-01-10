# Running commands inside container
```bash
docker exec -it --user root mariadb bash
cat /docker-entrypoint-initdb.d/init.sql
mysql -uroot -p
SHOW DATABASES;
USE ${MYSQL_DATABASE};
SHOW TABLES;
SELECT * FROM info;
```