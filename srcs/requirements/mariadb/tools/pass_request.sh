#!/bin/bash
# su -
# Trap SIGINT (Ctrl+C) and exit immediately
trap "echo 'Authentication canceled'; exit 1" SIGINT

# Get the current username
PAM_USER=$(whoami)


# Function to authenticate a user using PAM
authenticate_user() {
    local username="$PAM_USER"
    # local password="$PAM_AUTHTOK"

	if mysql -u"$username" -p"$password" -e "SELECT 1;" > /dev/null 2>&1; then
		# echo "Authenticated"
		exec "$@"
	else
		echo "Authentication failed"
		exit 1
	fi
}

# Call the authentication function
authenticate_user
