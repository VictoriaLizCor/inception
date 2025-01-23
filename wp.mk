wplog:
	$(CMD) logs wordpress
phpstat:
	$(CMD) exec wordpress ps aux | grep php-fpm
wpstat:
	$(CMD) exec wordpress wp core version
wp-credentials:
	curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sed -e "s/define('\(.*\)', *'\(.*\)');/\1=\2/"

twp:
	@docker exec -it --user root wordpress bash
wpDown:
	-@docker stop wordpress
	-@docker rmi wordpress
check-php:
	@docker exec wordpress curl -I http://localhost:9000 | grep "HTTP/1.1 200 OK" > /dev/null && \
	echo "PHP-FPM service is accessible." || \
	echo "PHP-FPM service is not accessible."
check-nc:
	@docker exec wordpress nc -zv wordpress 9000
wp-ping:
	-@export $(shell grep '^MYSQL' srcs/.env | xargs) && \
	docker exec wordpress mysqladmin ping -h"$$MYSQL_HOST" -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD"

### nginx
nglog:
	$(CMD) logs nginx
	docker exec -it --user root nginx bash -c "cat /var/log/nginx/error.log"
	docker exec -it --user root nginx bash -c "cat /var/log/nginx/access.log"
ngbash:
	@docker exec -it --user root nginx bash
ng-ping-maria:
	-@export $(shell grep '^MYSQL' srcs/.env | xargs) && \
	docker exec nginx mysqladmin ping -h"$$MYSQL_HOST" -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD"
ngself:
	docker exec nginx curl -kf https://localhost:443/healthcheck.html
	@echo
	docker exec nginx curl -kf https://lilizarr.42.fr/healthcheck.html

