#!/bin/bash

# Prompt for password
echo -n "Password: "
read -s password
echo

# Authenticate using PAM
if echo $password | sudo -S true 2>/dev/null; then
    exec "$@"
else
    echo "Authentication failed."
    exit 1
fi
