wplog:
	$(CMD) logs wordpress
phpstat:
	$(CMD) exec wordpress ps aux | grep php-fpm
wpstat:
	$(CMD) exec wordpress wp core version
wp-credentials:
	curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sed -e "s/define('\(.*\)', *'\(.*\)');/\1=\2/"
