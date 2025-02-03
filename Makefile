#------ SRC FILES & DIRECTORIES ------#
SRCS	:= srcs
D		:= 0
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
# export DOCKER_BUILDKIT=1
#-------------------- RULES ----------------------------#
all: buildAll up showAll

buildAll: $(VOLUMES) secrets
	@printf "\n$(LF)⚙️  $(P_BLUE) Building Images \n\n$(P_NC)";
ifneq ($(D), 0)
	@bash -c 'set -o pipefail; $(CMD) build 2>&1 | tee build.log || { echo "Error: Docker compose build failed. Check build.log for details."; exit 1; }'
else
	@bash -c 'set -o pipefail; $(CMD) build || { echo "Error: Docker compose build failed. Check build.log for details."; exit 1; }'
endif
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Builted Images! 🐳\n$(P_NC)"

# Function to remove a container if it exists
define remove_container
	@docker ps -aq -f name=$(1) | grep -q . && docker rm -f $(1) && echo "Removed container $(1)." || exit 0
endef

# Function to remove an image if it exists
define remove_image
	@docker images -q $(1) | grep -q . && docker rmi -f $(1) && echo "Removed image $(1)." || exit 0
endef

# Build Nginx image
build-nginx: $(VOLUMES) secrets check_host
	@printf "\n$(LF)⚙️  $(P_BLUE) Building Nginx image \n\n$(P_NC)";
	@bash -c 'set -o pipefail; $(CMD) build nginx 2>&1 | tee build-nginx.log || { echo "Error: Docker compose build failed. Check build-nginx.log for details."; exit 1; }'
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Built Nginx Image! 🐳\n$(P_NC)"

# Start Nginx container
up-nginx:
	@printf "$(LF)\n$(D_PURPLE)[+] Starting Nginx container $(P_NC)\n"
	@$(CMD) up -d nginx

# Check, remove, build, and start Nginx container
run-nginx: remove-nginx clean-nginx-cache build-nginx up-nginx
	@printf "\n$(LF)🚀 $(P_GREEN)Successfully Built and Started Nginx Container! 🚀\n$(P_NC)"

# Build MariaDB image
build-mariadb: $(VOLUMES) secrets #check_host
	@printf "\n$(LF)⚙️  $(P_BLUE) Building MariaDB image \n\n$(P_NC)";
	@bash -c 'set -o pipefail; $(CMD) build mariadb 2>&1 | tee build-mariadb.log || { echo "Error: Docker compose build failed. Check build-mariadb.log for details."; exit 1; }'
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Built MariaDB Image! 🐳\n$(P_NC)"

# Start MariaDB container
up-mariadb:
	@printf "$(LF)\n$(D_PURPLE)[+] Starting MariaDB container $(P_NC)\n"
	@$(CMD) up -d mariadb

# Check, remove, build, and start MariaDB container
run-mariadb: remove-mariadb build-mariadb up-mariadb
	@printf "\n$(LF)🚀 $(P_GREEN)Successfully Built and Started MariaDB Container! 🚀\n$(P_NC)"


# Remove Nginx container and image if they exist
remove-nginx:
	@if [ -n "$$(docker ps -q -f name=nginx)" ];  then \
		docker stop nginx; \
		docker run --rm -v /home/lilizarr/data/wordpress:/var/www/html nginx bash -c "rm -rf /var/www/html/*"; \
	fi
	$(call remove_container,nginx)
	$(call remove_image,nginx)

# Remove MariaDB container and image if they exist
remove-mariadb:
	@if [ -n "$$(docker ps -q -f name=mariadb)" ]; then \
		docker stop mariadb ; \
		docker run --rm -v /home/lilizarr/data/mariadb:/var/lib/mysql mariadb bash -c "rm -rf /var/lib/mysql/*"; \
	fi
	$(call remove_container,mariadb)
	$(call remove_image,mariadb)

# Remove WordPress container and image if they exist
remove-wordpress:
	@if [ -n "$$(docker ps -q -f name=wordpress)" ];  then \
		docker stop wordpress; \
		docker run --rm -v /home/lilizarr/data/wordpress:/var/www/html wordpress bash -c "rm -rf /var/www/html/*"; \
	fi
	$(call remove_container,wordpress)
	$(call remove_image,wordpress)

# Build WordPress image
build-wordpress: $(VOLUMES) secrets clean-wordpress-cache #check_host
	@printf "\n$(LF)⚙️  $(P_BLUE) Building WordPress image \n\n$(P_NC)";
	@bash -c 'set -o pipefail; $(CMD) build wordpress 2>&1 | tee build-wordpress.log || { echo "Error: Docker compose build failed. Check build-wordpress.log for details."; exit 1; }'
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Built WordPress Image! 🐳\n$(P_NC)"

# Start WordPress container
up-wordpress:
	@printf "$(LF)\n$(D_PURPLE)[+] Starting WordPress container $(P_NC)\n"
	@$(CMD) up -d wordpress

# Check, remove, build, and start WordPress container
run-wordpress: remove-wordpress build-wordpress up-wordpress
	@printf "\n$(LF)🚀 $(P_GREEN)Successfully Built and Started WordPress Container! 🚀\n$(P_NC)"


# Build and start all containers
run: $(VOLUMES) secrets run-mariadb run-wordpress run-nginx
	@printf "\n$(LF)🚀 $(P_GREEN)Successfully Built and Started All Containers! 🚀\n$(P_NC)"

$(VOLUMES): #check_os
	@printf "$(LF)\n$(P_BLUE)⚙️  Setting $(P_YELLOW)$(NAME)'s volumes$(FG_TEXT)\n"
	$(call createDir,$(WP_VOL))
	$(call createDir,$(DB_VOL))

down:
	@printf "$(LF)\n$(P_RED)[-] Phase of stopping and deleting containers $(P_NC)\n"
	@if [ -n "$$(docker ps -q)" ]; then \
		$(CMD) down -v --rmi local ;\
	fi

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

remove_containers:
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


clean: #remove-nginx remove-wordpress remove-mariadb 
	@printf "\n$(LF)🧹 $(P_RED) Clean $(P_GREEN) $(CURRENT)\n"
	@printf "$(LF)\n  $(P_RED)❗  Removing $(FG_TEXT)"
	@$(MAKE) --no-print stop down
	@rm -rf srcs/*.log

fclean: clean remove_containers remove_images remove_volumes prune remove_networks rm-secrets
	-@if [ -d "$(VOLUMES)" ]; then	\
		rm -rf $(VOLUMES);		\
		printf "\n$(LF)🧹 $(P_RED) Clean $(P_YELLOW)Volume's Volume files$(P_NC)\n"; \
	fi
	@printf "$(LF)"
	@echo $(WHITE) "$$TRASH" $(E_NC)

rm-secrets: clean_host
	-@if [ -d "./secrets" ]; then	\
		printf "$(LF)  $(P_RED)❗  Removing $(P_YELLOW)Secrets files$(FG_TEXT)"; \
		find ./secrets -type f -exec shred -u {} \;; \
		rm -rf ./secrets ; \
	fi
	-@if [ -f "$(SRCS)/.env" ]; then \
		shred -u $(SRCS)/.env; \
	fi

secrets: check_host
	@$(call createDir,./secrets)
	@chmod +x generateSecrets.sh
	@echo $(WHITE)
# @export $(shell grep '^TMP' srcs/.env.tmp | xargs) && \
	bash generateSecrets.sh $$TMP #for testing
	@bash generateSecrets.sh
	@echo $(E_NC) > /dev/null

showData:
	-@sudo ls ~/data/mariadb/ -Rla

re: fclean all


.PHONY: all buildAll set build up down clean fclean status logs restart re showAll check_os rm-secrets remove_images remove_containers remove_volumes remove_networks prune showData secrets check_host