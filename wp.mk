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
	docker exec wordpress mysqladmin ping -h"$$MYSQL_HOST" -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD"; \
	docker exec wordpress nc -zv localhost 9000

clean-wordpress-cache:
	@echo "Cleaning Docker cache for Nginx..."
	@docker image rm wordpress:latest || true

### nginx
nglog:
	-$(CMD) logs nginx
	-docker exec -it --user root nginx bash -c "cat /var/log/nginx/error.log"
	-docker exec -it --user root nginx bash -c "cat /var/log/nginx/access.log"
ngbash:
	@docker exec -it --user root nginx bash
ng-ping-maria:
	-@export $(shell grep '^MYSQL' srcs/.env | xargs) && \
	docker exec nginx mysqladmin ping -h"$$MYSQL_HOST" -u"$$MYSQL_USER" -p"$$MYSQL_PASSWORD"
ngself:
	docker exec nginx curl -kf https://localhost:443/healthcheck.html
	docker exec nginx curl -kf https://localhost:443/site-health.php

clean-nginx-cache:
	@echo "Cleaning Docker cache for Nginx..."
	@docker image rm nginx:latest || true

web:
	@echo "Opening Firefox in incognito mode..."
	@firefox --private-window https://lilizarr.42.fr &

wp-ng:
	@printf "$(LF)\n$(D_PURPLE)[+] Stopping Nginx and MariaDB containers $(P_NC)\n"
	@$(CMD) stop nginx wordpress
	@printf "$(LF)\n$(D_PURPLE)[+] Removing Nginx and MariaDB containers $(P_NC)\n"
	@$(CMD) rm -f  wordpress nginx
	@printf "$(LF)\n$(D_PURPLE)[+] Removing Nginx and MariaDB images $(P_NC)\n"
	-@docker rmi wordpress nginx
	@$(CMD) build wordpress nginx --no-cache
	@$(CMD) up -d wordpress nginx
