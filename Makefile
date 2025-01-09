-include tools.mk
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

#-------------------- RULES ----------------------------#
all: build up showAll#up

build: check_os secrets check_host $(VOLUMES) #add_docker_group
	@printf "\n$(LF)⚙️  $(P_BLUE) Building images \n\n$(P_NC)"
	@$(CMD) build 
#--no-cache
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Built Docker Images! 🐳\n$(P_NC)"
	@echo $(CYAN) "$$IMG" $(E_NC)
	@echo "$$MANUAL" $(E_NC)

$(VOLUMES):
	$(call createDir,$(WP_VOL))
	$(call createDir,$(DB_VOL))


down:
	@printf "$(LF)$(P_RED)[-] Phase of stopping and deleting containers ...$(P_NC)\n"
	@$(CMD) down -v

up:
	@printf "$(LF)$(D_PURPLE)[+] Phase of creating containers ...$(P_NC)\n"
	@$(CMD) up -d

stop:
	@printf "$(LF)$(P_RED)❗  Stopping containers ...$(P_NC)\n"
	@if [ -n "$$(docker ps -q)" ]; then \
		$(CMD) stop; \
	else \
		printf "$(LF)$(P_YELLOW)No running containers to stop.$(P_NC)\n"; \
	fi

up_detach:
	@printf "$(LF)$(P_CCYN)[+] Phase of creating containers in detach mode ...$(P_NC)\n"
	@$(CMD) up -d

remove_images:
	@printf "$(LF)$(P_RED)❗  Deleting images ...$(P_NC)\n"
	@if [ -n "$$(docker image ls -q)" ]; then \
		docker image rm -f $$(docker image ls -q); \
	else \
		printf "$(LF)$(P_YELLOW)No images to remove.$(P_NC)\n"; \
	fi

remove_containers:
	@printf "$(LF)$(P_RED)❗  Deleting containers ...$(P_NC)\n"
	@if [ -n "$$(docker container ls -aq)" ]; then \
		docker container rm -f $$(docker container ls -aq); \
	else \
		printf "$(LF)$(P_YELLOW)No containers to remove.$(P_NC)\n"; \
	fi

remove_volumes:
	@printf "$(LF)$(P_RED)❗  Removing volumes ...$(P_NC)\n"
	@sudo rm -rf $(VOLUMES)
	@if [ -n "$$(docker volume ls -q)" ]; then \
		docker volume rm $$(docker volume ls -q); \
	else \
		printf "$(LF)$(P_YELLOW)No volumes to remove.$(P_NC)\n"; \
	fi

remove_networks:
	@printf "$(LF)$(P_RED)❗  Removing networks ...$(P_NC)\n"
	-@docker network rm $(shell docker network ls -q) 2>/dev/null

prune:
	@docker image prune -a -f

show:
	@printf "$(LF)$(D_PURPLE)* List of all running containers$(P_NC)\n"
	@docker container ls

showAll:
	@printf "$(LF)$(D_PURPLE)* List all running and sleeping containers$(P_NC)\n"
	@docker container ls -a
	@printf "$(LF)$(D_PURPLE)* List all images$(P_NC)\n"
	@docker image ls
	@printf "$(LF)$(D_PURPLE)* List all volumes$(P_NC)\n"
	@docker volume ls
	@printf "$(LF)$(D_PURPLE)* List all networks$(P_NC)\n"
	@docker network ls

clean: stop rm-secrets remove_containers remove_volumes prune remove_networks
	@echo 
	-@if [ -d "$(VOLUMES)" ]; then	\
		sudo rm -rf $(VOLUMES);		\
		printf "$(LF)🧹 $(P_RED) Clean $(P_YELLOW)Volume's Volume files$(P_NC)\n"; \
	fi
	@printf  "\n$(P_NC)"

fclean: clean
	@printf "$(LF)🧹 $(P_RED) Clean $(P_GREEN) $(CURRENT)\n"
	@echo $(WHITE) "$$TRASH" $(E_NC)
	@echo


rm-secrets: clean_host
	-@if [ -d "./secrets" ]; then	\
		printf "$(LF)🧹 $(P_RED) Clean $(P_YELLOW)Secrets's files$(P_NC)\n"; \
		find ./secrets -type f -exec shred -u {} \; \
		rm -rf ./secrets
	-@shred -u $(SRCS)/.env

secrets:
	@chmod +x generateSecrets.sh
	@$(call createDir,./secrets)
	@echo $(WHITE)
	@bash generateSecrets.sh
	@echo $(E_NC)


showData:
	-@sudo ls ~/data/mariadb/ -Rla

re: fclean all


.PHONY: all set build up down clean fclean status logs restart re showAll secrets