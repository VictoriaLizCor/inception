
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

#docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null

define createDir
	@if [ -d "$(1)" ]; then \
		printf "\n$(LF)🔍 $(P_BLUE)Directory $(P_YELLOW)$(1) $(P_BLUE)already exists$(FG_TEXT)\n"; \
	else \
		printf "\n$(LF)🚧 $(P_BLUE)Creating directory $(P_YELLOW)$(1) $(P_BLUE)and setting permissions$(FG_TEXT)\n"; \
		mkdir -p $(1); \
		chmod u+rwx $(1); \
		printf "$(LF)☑️  $(P_BLUE)Successfully created directory $(P_GREEN)$(1) $(P_BLUE)! ☑️$(P_NC)\n"; \
	fi
endef


#-------------------- RULES ----------------------------#
all: check_os build #up

build: $(VOLUMES) #add_docker_group
ifneq ($(D), 0)
	@printf "$(LF)\n$(P_BLUE)☑️  Successfully Created $(P_YELLOW)$(NAME)'s Object files ☑️$(FG_TEXT)\n"
endif
	@printf "\n"
	@printf "$(LF)⚙️ $(P_BLUE) Phase of building images ⚙️\n"
	@echo $(YELLOW)
	@printf "Docker compose build $(FG_TEXT) \n\n";
	@$(CMD) build
	@printf "\n$(LF)🐳 $(P_BLUE)Successfully Built Docker Images! 🐳\n$(P_NC)"
	@echo $(CYAN) "$$IMG" $(E_NC)
	@echo "$$MANUAL" $(E_NC)

$(VOLUMES):
	$(call createDir,$(WP_VOL))
	$(call createDir,$(DB_VOL))

down:
	@printf "$(LF)$(P_RED)[-] Phase of stopping and deleting containers ...$(P_NC)\n"
	@$(DOCKER_COMPOSE) -f $(path) down -v

up:
	@printf "$(LF)$(D_PURPLE)[+] Phase of creating containers ...$(P_NC)\n"
	@$(DOCKER_COMPOSE) -f $(path) up

stop:
	@printf "$(LF)$(P_RED)[!] Phase of stopping containers ...$(P_NC)\n"
	@$(DOCKER_COMPOSE) -f $(path) stop

up_detach:
	@printf "$(LF)$(P_CCYN)[+] Phase of creating containers in detach mode ...$(P_NC)\n"
	@$(DOCKER_COMPOSE) -f $(path) up -d

remove_images:
	@printf "$(LF)$(P_RED)[!] Deleting images ...$(P_NC)\n"
	@docker image rm -f $(shell docker image ls -q)

remove_containers:
	@printf "$(LF)$(P_RED)[!] Forcibly deleting containers ...$(P_NC)\n"
	@docker container rm -f $(shell docker container ls -aq)

remove_volumes:
	@printf "$(LF)$(P_RED)Removing volumes ...$(P_NC)\n"
	@rm -rf /home/$(shell echo $$USER)/data/database/ /home/$(shell echo $$USER)/data/files
	@docker volume rm $(shell docker volume ls -q)

remove_networks:
	@printf "$(LF)$(P_RED) Removing networks ...$(P_NC)\n"
	@docker network rm inception

show:
	@printf "$(LF)$(D_PURPLE)[.] List of all running containers$(P_NC)\n"
	@docker container ls

show_all:
	@printf "$(LF)$(D_PURPLE)[.] List all running and sleeping containers$(P_NC)\n"
	@docker container ls -a
	@printf "$(LF)$(D_PURPLE)[.] List all images$(P_NC)\n"
	@docker image ls
	@printf "$(LF)$(D_PURPLE)[.] List all volumes$(P_NC)\n"
	@docker volume ls
	@printf "$(LF)$(D_PURPLE)[.] List all networks$(P_NC)\n"
	@docker network ls

.PHONY: all set build up down clean fclean status logs restart re help show_all

clean:
	@echo;
	@if [ -d "$(VOLUMES)" ]; then	\
		rm -rf $(VOLUMES); 		\
		printf "$(LF)🧹 $(P_RED) Clean $(P_YELLOW)$(NAME)'s Volume files$(P_NC)\n"; \
	fi
	@printf  "\n$(P_NC)"

fclean: clean
	@if [ -f $(NAME) ]; then	\
		printf "$(LF)🧹 $(P_RED) Clean $(P_GREEN) $(CURRENT)/$(NAME)\n";	\
		rm -rf $(NAME);														\
		echo $(WHITE) "$$TRASH" $(E_NC);									\
	else																	\
		printf "$(LF)🧹$(P_RED) Clean $(P_GREEN) $(CURRENT)\n";			\
	fi
	@printf "\n$(P_NC)"

re: fclean all


# #-------------------- GIT UTILS ----------------------------#
info:
	@echo GIT_REPO:  $(CYAN) $(GIT_REPO) $(E_NC)
	@echo PROJECT_ROOT: $(CYAN) $(PROJECT_ROOT) $(E_NC)
	@echo CURRENT: $(GREEN) $(CURRENT) $(E_NC)
	@echo SRC: $(YELLOW) $(SRC) $(E_NC)
	@echo OBJS: $(GRAY) $(OBJS) $(E_NC)

gAdd:
	@echo $(CYAN) && git add .
gCommit:
	@echo $(GREEN) && git commit -e ; \
	ret=$$?; \
	if [ $$ret -ne 0 ]; then \
		echo $(RED) "Error in commit message"; \
		exit 1; \
	fi
gPush:
	@echo $(YELLOW) && git push ; \
	ret=$$? ; \
	if [ $$ret -ne 0 ]; then \
		echo $(RED) "git push failed, setting upstream branch" $(YELLOW) && \
		git push --set-upstream origin $(shell git branch --show-current) || \
		if [ $$? -ne 0 ]; then \
			echo $(RED) "git push --set-upstream failed with error" $(E_NC); \
			exit 1; \
		fi \
	fi
git: fclean gAdd gCommit gPush

check_os:
	@printf "$(LF)$(P_CCYN)⚙️  Checking if the operating system is $(D_PURPLE)Debian:Bullseye...$(FG_TEXT)\n"
	@if [ -f /etc/os-release ]; then \
		. /etc/os-release; \
		echo ; \
		if [ "$$ID" = "debian" ] && [ "$$VERSION_CODENAME" = "bullseye" ]; then \
			printf "$(LF)$(P_GREEN)...✅ The operating system is Debian:Bullseye! ✅$(P_NC)\n"; \
		else \
			printf "$(LF)$(P_RED)...❌ The operating system is not Debian:Bullseye! ❌$(P_NC)\n"; \
			exit 1; \
		fi \
	else \
		printf "$(LF)$(P_RED)...❌ The operating system is not Debian:Bullseye! ❌$(P_NC)\n"; \
		exit 1; \
	fi
	echo

add_docker_group:
	@echo "$(D_PURPLE)[*] Adding user to docker group ...$(P_NC)"
	@sudo usermod -aG docker $(shell whoami)

# --- DOCKER INSTALL
install_docker:
	@if command -v docker >/dev/null 2>&1; then \
		printf "$(LF)$(P_GREEN)✅ Docker is already installed! ✅$(P_NC)\n"; \
	else \
		printf "$(LF)$(P_CCYN)⚙️  Updating package list...$(FG_TEXT)\n"; \
		sudo apt-get update; \
		printf "$(LF)$(P_CCYN)⚙️  Installing prerequisites...$(FG_TEXT)\n"; \
		sudo apt-get install -y \
			ca-certificates \
			curl \
			gnupg \
			lsb-release; \
		printf "$(LF)$(P_CCYN)⚙️  Adding Docker's official GPG key...$(FG_TEXT)\n"; \
		curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; \
		printf "$(LF)$(P_CCYN)⚙️  Setting up the Docker repository...$(FG_TEXT)\n"; \
		echo \
		  "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $$(lsb_release -cs) stable" | \
		  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; \
		printf "$(LF)$(P_CCYN)⚙️  Updating package list again...$(FG_TEXT)\n"; \
		sudo apt-get update; \
		printf "$(LF)$(P_CCYN)⚙️  Installing Docker...$(FG_TEXT)\n"; \
		sudo apt-get install -y docker-ce docker-ce-cli containerd.io; \
		printf "$(LF)$(P_GREEN)✅ Successfully installed Docker! ✅$(P_NC)\n"; \
	fi
cpy:
	@scp -r ./* Debian:inception
#--------------------COLORS----------------------------#
# For print
CL_BOLD  = \e[1m
RAN	 	 = \033[48;5;237m\033[38;5;255m
D_PURPLE = \033[1;38;2;189;147;249m
D_WHITE  = \033[1;37m
NC	  	 = \033[m
P_RED	 = \e[1;91m
P_GREEN  = \e[1;32m
P_BLUE   = \e[0;36m
P_YELLOW = \e[1;33m
P_CCYN   = \e[0;1;36m
P_NC	 = \e[0m
LF	   = \e[1K\r$(P_NC)
FG_TEXT  = $(P_NC)\e[38;2;189;147;249m
# For bash echo
CLEAR  = "\033c"
BOLD   = "\033[1m"
CROSS  = "\033[8m"
E_NC   = "\033[m"
RED	= "\033[1;31m"
GREEN  = "\033[1;32m"
YELLOW = "\033[1;33m"
BLUE   = "\033[1;34m"
WHITE  = "\033[1;37m"
MAG	= "\033[1;35m"
CYAN   = "\033[0;1;36m"
GRAY   = "\033[1;90m"
PURPLE = "\033[1;38;2;189;147;249m"

define IMG

		⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢰⢲⠐⡖⡆⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣸⣀⣇⡇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣿⣿⣿⣿⣿⣿⣿⠀⡤⡤⡤⣤⢠⡤⡤⡤⡄⢠⢤⡤⡤⡄⢸⣿⣿⣿⣿⣿⣿⣿⡟⢿⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣿⣿⣿⣿⣿⣿⣿⠀⡇⡇⡇⣿⢸⡇⡇⡇⡇⢸⢸⠀⡇⡇⢸⣿⣿⣿⣿⣿⣿⡟⢠⣦⡈⢿⣿⣿⣿⣿⣿⣿
		⣿⣿⣿⠉⣉⣉⣉⣉⠀⣉⣉⣉⣉⢈⣉⣉⣉⡁⢈⣉⣉⣉⡁⢈⣉⣉⣉⡉⣿⣿⠀⣿⣿⣿⡀⠿⠿⠿⢿⣿⣿
		⣿⣿⣿⠀⡇⡇⣿⢸⠀⡇⡇⡇⣿⢸⡇⡇⡇⡇⢸⢸⠉⡇⡇⢸⢸⢸⠁⡇⢸⣿⡄⢻⣿⣿⢣⣶⣶⣶⣦⠄⣹
		⡿⠻⠻⠀⠓⠓⠛⠚⠀⠓⠓⠓⠛⠘⠓⠓⠓⠃⠘⠚⠒⠓⠃⠘⠚⠚⠒⠃⠘⠛⢃⣠⣿⢣⣿⣿⡿⠟⢋⣴⣿
		⡇⢸⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣱⠃⣤⣤⣶⣾⣿⣿⣿
		⣷⠘⡟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟⣽⠃⣰⣿⣿⣿⣿⣿⣿⣿
		⣿⡄⢻⣹⣿⣿⣿⣿⣿⣿⣿⣿⢫⠂⢯⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣫⡿⢁⣼⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣧⡈⢷⡻⣿⣿⣿⣿⣿⠟⣿⣯⣖⣮⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣫⡾⠋⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣿⣷⣄⠉⣉⣉⣉⣉⣤⣶⣎⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣵⠟⢋⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣿⣿⣿⣷⣌⠙⠿⣭⣟⣻⣿⢿⣯⡻⢿⣿⣿⣿⣿⣿⠿⠟⠛⣉⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
		⣿⣿⣿⣿⣿⣿⣿⣶⣦⣬⣉⣉⣛⣛⣛⣓⣈⣉⣉⣤⣤⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿

endef
export IMG

define TRASH

		⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀
		⠀⠀⠀⠀⣰⣾⠋⠙⠛⣿⡟⠛⣿⣿⣿⣷⣆⠀⠀⠀⠀
		⠀⠀⢠⣾⣿⣿⣷⣶⣤⣀⡀⠐⠛⠿⢿⣿⣿⣷⡄⠀⠀
		⠀⢠⣿⣿⣿⡿⠿⠿⠿⠿⠿⠿⠶⠦⠤⢠⣿⣿⣿⡄⠀
		⠀⣾⣿⣿⣿⣿⠀⣤⡀⠀⣤⠀⠀⣤⠀⢸⣿⣿⣿⣷⠀
		⠀⣿⣿⣿⣿⣿⠀⢿⡇⠀⣿⠀⢠⣿⠀⣿⣿⣿⣿⣿⠀
		⠀⢿⣿⣿⣿⣿⡄⢸⡇⠀⣿⠀⢸⡏⠀⣿⣿⣿⣿⡿⠀
		⠀⠘⣿⣿⣿⣿⡇⢸⡇⠀⣿⠀⢸⡇⢠⣿⣿⣿⣿⠃⠀
		⠀⠀⠘⢿⣿⣿⡇⢸⣧⠀⣿⠀⣼⡇⢸⣿⣿⡿⠁⠀⠀
		⠀⠀⠀⠀⠻⢿⣷⡘⠛⠀⠛⠀⠸⢃⣼⡿⠟⠀⠀⠀⠀
		⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠛⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀
endef
export TRASH

define MANUAL

Example:
$(D_WHITE)[test]
$(D_PURPLE)$> make D=0 test
$(D_WHITE)[test + DEBUG]
$(D_PURPLE)$> make D=1 test
$(D_WHITE)[DEBUG + Valgrind]
$(D_PURPLE)$> make D=1 S=0 re val
$(D_WHITE)[DEBUG + Sanitizer]
$(D_PURPLE)$> make D=1 S=1 re test

endef
export MANUAL
