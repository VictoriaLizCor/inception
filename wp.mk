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
	@docker stop wordpress
	@docker rm wordpress
	@docker rmi wordpress
check-php:
	@docker exec wordpress curl -I http://localhost:9000 | grep "HTTP/1.1 200 OK" > /dev/null && \
	echo "PHP-FPM service is accessible." || \
	echo "PHP-FPM service is not accessible."
check-nc:
	@docker exec wordpress nc -zv wordpress 9000
