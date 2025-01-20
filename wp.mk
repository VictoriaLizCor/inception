wplog:
	$(CMD) logs wordpress
phpstat:
	$(CMD) exec wordpress ps aux | grep php-fpm
wpstat:
	$(CMD) exec wordpress wp core version
wp-credentials:
	curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sed -e "s/define('\(.*\)', *'\(.*\)');/\1=\2/"


twp:
	@docker exec -it --user root wp bash
wpDown:
	@$(CMD) down worpress
	@$(CMD)  rm -f wordpress
	@docker rmi wordpress