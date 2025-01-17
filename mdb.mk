# ---------------- MARIA DB STATUS CHECK RULES ------------------
mariadb:
	$(CMD) build --no-cache mariadb
rmdb:
	@docker exec -it --user root mariadb bash
mdb:
	@docker exec -it --user mysql mariadb bash
logm:
	@docker logs -f mariadb
mrstat:
	@docker exec -it --user root mariadb mysqladmin -u root -p status
mstat:
	@docker exec -it --user mysql mariadb mysqladmin -u mysql -p status
mdblog:
	@docker exec -it --user root mariadb bash -c "cat /var/log/mysql/error.log"
catdb:
	@docker exec -it --user root mariadb mysql -uroot -p -e "SELECT User, Host FROM mysql.user;SHOW DATABASES; USE db; SELECT * FROM info;"
rhealth:
	@docker exec -it mariadb mysqladmin ping -h localhost -u root -p