#------ SRC FILES & DIRECTORIES ------#
SRCS	:= srcs
CMD		:= cd $(SRCS) && docker compose
PROJECT_ROOT:= $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../)
GIT_REPO	:=$(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
CURRENT		:= $(shell basename $$PWD)
VOLUMES		:= $(HOME)/data
WP_VOL		:= $(VOLUMES)/wordpress
DB_VOL		:= $(VOLUMES)/mariadb
MDB			:= $(SRCS)/requirements/mariadb
WP			:= $(SRCS)/requirements/wordpress
NG			:= $(SRCS)/requirements/nginx
NAME		:= Inception
-include tools.mk mdb.mk wp.mk
#-------------------- RULES ----------------------------#
all: run showAll#up

test: 
	@$(CMD) up -d wp

build-mariadb: $(VOLUMES) secrets check_host
	@printf "\n$(LF)⚙️  $(P_BLUE) Building MariaDB image \n\n$(P_NC)";
	@bash -c 'set -o pipefail; $(CMD) build mariadb 2>&1 | tee build-mariadb.log || { echo "Error: Docker compose build failed. Check build-wordpress.log for details."; exit 1; }'
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Built MariaDB Image! 🐳\n$(P_NC)"

build-wordpress: $(VOLUMES) secrets check_host
	@printf "\n$(LF)⚙️  $(P_BLUE) Building WordPress image \n\n$(P_NC)";
	@bash -c 'set -o pipefail; $(CMD) build wordpress 2>&1 | tee build-wordpress.log || { echo "Error: Docker compose build failed. Check build-wordpress.log for details."; exit 1; }'
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Built WordPress Image! 🐳\n$(P_NC)"

up-mariadb:
	@printf "$(LF)\n$(D_PURPLE)[+] Starting MariaDB container $(P_NC)\n"
	@$(CMD) up -d mariadb

up-wordpress:
	@printf "$(LF)\n$(D_PURPLE)[+] Starting WordPress container $(P_NC)\n"
	@$(CMD) up -d wordpress

run-mariadb: build-mariadb up-mariadb 
	@printf "\n$(LF)🚀 $(P_GREEN)Successfully Built and Started MariaDB Container! 🚀\n$(P_NC)"

run-wordpress: build-wordpress up-wordpress
	@printf "\n$(LF)🚀 $(P_GREEN)Successfully Built and Started WordPress Container! 🚀\n$(P_NC)"

run: $(VOLUMES) secrets check_host run-mariadb run-wordpress
	@printf "\n$(LF)🚀 $(P_GREEN)Successfully Built and Started All Containers! 🚀\n$(P_NC)"


$(VOLUMES): check_os
	@printf "$(LF)\n$(P_BLUE)⚙️  Setting $(P_YELLOW)$(NAME)'s volumes$(FG_TEXT)\n"
	$(call createDir,$(WP_VOL))
	$(call createDir,$(DB_VOL))
	@$(call createDir,./secrets)

down:
	@printf "$(LF)\n$(P_RED)[-] Phase of stopping and deleting containers $(P_NC)\n"
	@$(CMD) down -v --rmi local

up:
	@printf "$(LF)\n$(D_PURPLE)[+] Phase of creating containers $(P_NC)\n"
	@$(CMD) up -d

stop:
	@printf "$(LF)$(P_RED)  ❗  Stopping $(P_YELLOW)Containers $(P_NC)\n"
	@if [ -n "$$(docker ps -q)" ]; then \
		$(CMD) stop ;\
	fi

remove_images:
	@printf "$(FG_TEXT)$(LF)$(P_RED)  ❗  Deleting $(P_YELLOW)images $(FG_TEXT)"
	@if [ -n "$$(docker image ls -q)" ]; then \
		docker image rm -f $$(docker image ls -q) > /dev/null; \
	fi

remove_containers: rm-secrets
	@printf "$(LF)$(P_RED)  ❗  Deleting containers $(FG_TEXT)"
	@if [ -n "$$(docker container ls -aq)" ]; then \
		docker container rm -f $$(docker container ls -aq) > /dev/null; \
	fi

remove_volumes:
	@printf "$(LF)$(P_RED)  ❗  Removing $(P_YELLOW)Volumes $(FG_TEXT)"
	@sudo rm -rf $(VOLUMES)
	@if [ -n "$$(docker volume ls -q)" ]; then \
		docker volume rm $$(docker volume ls -q) > /dev/null; \
	fi


remove_networks:
	@printf "$(LF)$(P_RED)  ❗  Removing $(P_YELLOW)networks $(FG_TEXT)"
	@docker network ls --filter "type=custom" -q | xargs -r docker network rm > /dev/null

prune:
	@docker image prune -af > /dev/null
	@docker builder prune -af > /dev/null
	@docker system prune -af > /dev/null
	@docker volume prune -f > /dev/null


clean:
	@printf "\n$(LF)🧹 $(P_RED) Clean $(P_GREEN) $(CURRENT)\n"
	@printf "$(LF)\n  $(P_RED)❗  Removing $(FG_TEXT)"
	@$(MAKE) --no-print stop down

fclean: clean remove_containers remove_images  remove_volumes prune remove_networks
	-@if [ -d "$(VOLUMES)" ]; then	\
		rm -rf $(VOLUMES);		\
		printf "\n$(LF)🧹 $(P_RED) Clean $(P_YELLOW)Volume's Volume files$(P_NC)\n"; \
	fi
	@printf "$(LF)"
	@echo $(WHITE) "$$TRASH" $(E_NC)

rm-secrets: clean_host
	@if [ -d "./secrets" ]; then	\
		printf "$(LF)  $(P_RED)❗  Removing $(P_YELLOW)Secrets files$(FG_TEXT)"; \
		find ./secrets -type f -exec shred -u {} \;; \
		rm -rf ./secrets ; \
	fi
	-@if [ -f "$(SRCS)/.env" ]; then \
		shred -u $(SRCS)/.env; \
	fi

secrets:
	@chmod +x generateSecrets.sh
	@echo $(WHITE)
	@bash generateSecrets.sh
	@echo $(E_NC) > /dev/null

showData:
	-@sudo ls ~/data/mariadb/ -Rla

re: fclean all


.PHONY: all set build up down clean fclean status logs restart re showAll  check_host check_os rm-secrets remove_images remove_containers remove_volumes remove_networks prune showData secrets