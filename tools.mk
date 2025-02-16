
all:
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
# #-------------------- GIT UTILS ----------------------------#
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
git: gAdd gCommit gPush

# #-------------------- Check OS dependencies ----------------------#
check_os:
	@printf "\n$(LF)$(P_CCYN)🚧  Checking if the operating system is $(D_PURPLE)Debian:Bullseye...$(FG_TEXT)"
	@if hostnamectl | grep -q "Operating System: Debian GNU/Linux 11 (bullseye)"; then \
		printf "$(LF)$(D_PURPLE)🏁  The operating system is Debian:Bullseye! $(P_NC)\n"; \
	else \
		printf "$(LF)$(P_RED)...❌ The operating system is not Debian:Bullseye! ❌$(P_NC)\n"; \
		exit 1; \
	fi

add_docker_group:
	@echo "$(D_PURPLE)[*] Adding user to docker group ...$(P_NC)"
	@sudo usermod -aG docker $(shell whoami)
	@sudo systemctl restart docker

rm_docker_group:
	@echo "$(D_PURPLE)[*] Removing user from docker group ...$(P_NC)"
	@sudo gpasswd -d $(shell whoami) docker
	@sudo systemctl restart docker

encrypt:
	@rm -f srcs/.env .tmp.enc .tmp.tar.gz
	@tar -czf .tmp.tar.gz srcs/requirements/nginx/conf/ssl srcs/.env.tmp
	@bash -c ' \
	read -sp "Please enter some input: " user_input; \
	echo; \
	gpg --batch --passphrase "$$user_input" --symmetric --cipher-algo AES256 -o .tmp.enc .tmp.tar.gz '
	@rm .tmp.tar.gz

# @rm -rf .srcs/.env
# @bash -c ' \
# read -sp "Please enter some input: " user_input; \
# echo; \
# openssl enc -aes-256-cbc -salt -pbkdf2 -in srcs/.env.tmp -out srcs/.env.enc -k "$$user_input" \

cert: 
	@mkcert -key-file srcs/requirements/nginx/conf/ssl/privkey.key -cert-file srcs/requirements/nginx/conf/ssl/fullchain.crt ${USER}.42.fr


# cert:
# 	@echo "Generating SSL certificates..."
# 	@mkdir -p srcs/requirements/nginx/ssl && \
# 	export $(shell grep '^NGINX' srcs/.env | xargs) && \
# 	openssl req -new -newkey rsa:4096 -nodes -keyout $$NGINX_LOCAL_KEY -out $$NGINX_LOCAL_CERT -subj "$$NGINX_OPTIONS" && sleep 1 && \
# 	openssl x509 -req -days 365 -in $$NGINX_LOCAL_CERT -signkey $$NGINX_LOCAL_KEY -out srcs/requirements/nginx/ssl/nginx.crt && \
# 	echo "SSL certificates generated successfully."
# #-------------------- DOCKER isntall ----------------------------#
install_docker:
	@if command -v docker >/dev/null 2>&1; then \
		printf "$(LF)$(D_PURPLE)🟢  Docker is already installed! $(P_NC)\n"; \
	else \
		printf "$(LF)$(P_CCYN)⚙️  Updating package list...$(FG_TEXT)\n"; \
		sudo apt-get update; \
		printf "$(LF)$(P_CCYN)⚙️  Installing prerequisites...$(FG_TEXT)\n"; \
		sudo apt-get install -y \
			ca-certificates \
			curl \
			gnupg; \
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
	@if docker compose version >/dev/null 2>&1; then \
		printf "$(LF)$(D_PURPLE)🟢  Docker Compose is already installed! $(P_NC)\n"; \
	else \
		printf "$(LF)$(P_CCYN)⚙️  Installing Docker Compose...$(FG_TEXT)\n"; \
		sudo apt-get update; \
		sudo apt-get install -y ca-certificates curl gnupg; \
		sudo mkdir -p /etc/apt/keyrings; \
		curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
		echo \
		  "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; \
		sudo apt-get update; \
		sudo apt-get install -y docker-compose-plugin; \
		printf "$(LF)$(P_GREEN)✅ Successfully installed Docker Compose! ✅$(P_NC)\n"; \
	fi

# copy files from local machine to VM with ssh
cpy-host:
	@scp Debian:inception/* ./

cpy-VM:
	@scp -r ./* Debian:inception

check_host:
	@if grep -q "127.0.0.1 ${USER}.42.fr" /etc/hosts ; then \
		printf "$(LF)  🟢 $(P_BLUE)Host entry for $(P_YELLOW)${USER}.42.fr $(P_BLUE)already exists$(FG_TEXT)\n\n"; \
	else \
		printf "$(LF)🚧  $(P_BLUE)Creating host entry for $(P_YELLOW)${USER}.42.fr$(P_BLUE)$(FG_TEXT)\n"; \
		echo "127.0.0.1 ${USER}.42.fr" | sudo tee -a /etc/hosts > /dev/null; \
		printf "\n$(LF)  🟢  $(P_BLUE)Successfully created host entry for $(P_GREEN)${USER}.42.fr$(P_BLUE)! $(P_NC)\n\n"; \
	fi

clean_host:
	@if grep -q "127.0.0.1 ${USER}.42.fr" /etc/hosts; then \
		printf "$(LF)$(P_RED)  ❗  Removing host entry for $(P_YELLOW)${USER}.42.fr$(P_BLUE)$(FG_TEXT)"; \
		sudo sed -i "/127.0.0.1 ${USER}.42.fr/d" /etc/hosts; \
	fi
	@printf "$(LF)$(FG_TEXT)"; \

info:
	@echo GIT_REPO:  $(CYAN) $(GIT_REPO) $(E_NC)
	@echo PROJECT_ROOT: $(CYAN) $(PROJECT_ROOT) $(E_NC)
	@echo CURRENT: $(GREEN) $(CURRENT) $(E_NC)
	@echo SRC: $(YELLOW) $(SRC) $(E_NC)
	@echo OBJS: $(GRAY) $(OBJS) $(E_NC)

watch:
	@watch -n 1 ls -la $$HOME/data

define createDir
	@printf "\n$(LF)🚧  $(P_BLUE)Creating directory $(P_YELLOW)$(1) $(FG_TEXT)"; \
	if [ -d "$(1)" ]; then \
		printf "$(LF)  🟢 $(P_BLUE)Directory $(P_YELLOW)$(1) $(P_BLUE)already exists$(FG_TEXT)"; \
	else \
		mkdir -p $(1); \
		chmod 755 $(1); \
		printf "$(LF)  🟢  $(P_BLUE)Successfully created directory $(P_GREEN)$(1) $(P_BLUE)! $(FG_TEXT)"; \
	fi
	@echo
endef

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
