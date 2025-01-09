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
git: fclean gAdd gCommit gPush

check_os:
	@printf "\n$(LF)$(P_CCYN)🚧  Checking if the operating system is $(D_PURPLE)Debian:Bullseye...$(FG_TEXT)\n"
	@if [ -f /etc/os-release ]; then \
		. /etc/os-release; \
		echo ; \
		if [ "$$ID" = "debian" ] && [ "$$VERSION_CODENAME" = "bullseye" ]; then \
			printf "$(LF)$(D_PURPLE)🏁  The operating system is Debian:Bullseye! $(P_NC)\n"; \
		else \
			printf "$(LF)$(P_RED)...❌ The operating system is not Debian:Bullseye! ❌$(P_NC)\n"; \
			exit 1; \
		fi \
	else \
		printf "$(LF)$(P_RED)...❌ The operating system is not Debian:Bullseye! ❌$(P_NC)\n\n"; \
		exit 1; \
	fi
	@echo

add_docker_group:
	@echo "$(D_PURPLE)[*] Adding user to docker group ...$(P_NC)"
	@sudo usermod -aG docker $(shell whoami)
	@sudo systemctl restart docker

encrypt:
	@read -p "Please enter some input: " user_input; \
	openssl enc -aes-256-cbc -salt -pbkdf2 -in srcs/.env -out srcs/.env.enc -k $$user_input

# --- DOCKER INSTALL
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

check_host:
	@if grep -q "127.0.0.1 ${USER}.42.fr" /etc/hosts; then \
		printf "$(LF)🟢 $(P_BLUE)Host entry for $(P_YELLOW)${USER}.42.fr $(P_BLUE)already exists$(FG_TEXT)\n\n"; \
	else \
		printf "\n$(LF)🚧  $(P_BLUE)Creating host entry for $(P_YELLOW)${USER}.42.fr$(P_BLUE)$(FG_TEXT)\n"; \
		echo "127.0.0.1 ${USER}.42.fr" | sudo tee -a /etc/hosts; \
		printf "\n$(LF)✅  $(P_BLUE)Successfully created host entry for $(P_GREEN)${USER}.42.fr$(P_BLUE)! $(P_NC)\n\n"; \
	fi

clean_host:
	@if grep -q "127.0.0.1 ${USER}.42.fr" /etc/hosts; then \
		printf "\n$(LF)🚧  $(P_BLUE)Removing host entry for $(P_YELLOW)${USER}.42.fr$(P_BLUE)$(FG_TEXT)\n"; \
		sudo sed -i "/127.0.0.1 ${USER}.42.fr/d" /etc/hosts; \
		printf "\n$(LF)✅  $(P_BLUE)Successfully removed host entry for $(P_GREEN)${USER}.42.fr$(P_BLUE)! $(P_NC)\n\n"; \
	else \
		printf "$(LF)❌ $(P_BLUE)Host entry for $(P_YELLOW)${USER}.42.fr $(P_BLUE)does not exist$(FG_TEXT)\n\n"; \
	fi

info:
	@echo GIT_REPO:  $(CYAN) $(GIT_REPO) $(E_NC)
	@echo PROJECT_ROOT: $(CYAN) $(PROJECT_ROOT) $(E_NC)
	@echo CURRENT: $(GREEN) $(CURRENT) $(E_NC)
	@echo SRC: $(YELLOW) $(SRC) $(E_NC)
	@echo OBJS: $(GRAY) $(OBJS) $(E_NC)

watch:
	@watch -n 1 ls -la $$HOME/data

define createDir
	@if [ -d "$(1)" ]; then \
		printf "$(LF)🟢 $(P_BLUE)Directory $(P_YELLOW)$(1) $(P_BLUE)already exists$(FG_TEXT)\n\n"; \
	else \
		printf "\n$(LF)🚧  $(P_BLUE)Creating directory $(P_YELLOW)$(1) $(P_BLUE)and setting permissions $(FG_TEXT)"; \
		mkdir -p $(1); \
		chmod u+rwx $(1); \
		printf "\n$(LF)✅  $(P_BLUE)Successfully created directory $(P_GREEN)$(1) $(P_BLUE)! $(P_NC)\n\n"; \
	fi
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
