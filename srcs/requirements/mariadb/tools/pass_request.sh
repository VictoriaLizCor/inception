#!/bin/bash

# Trap SIGINT (Ctrl+C) and exit immediately
trap "echo 'Authentication canceled'; exit 1" SIGINT

# Get the current username
PAM_USER=$(whoami)

# Prompt for password
read -sp "Enter password for $PAM_USER: " PAM_AUTHTOK
echo

# Function to authenticate a user using PAM
authenticate_user() {
    local username="$PAM_USER"
    local password="$PAM_AUTHTOK"

    echo "$password" | su -c "echo 'Authenticated'" "$username" >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "Authentication successful for user: $username"
        exit 0
    else
        echo "Authentication failed for user: $username"
        exit 1
    fi
}

# Call the authentication function
authenticate_user
