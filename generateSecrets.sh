#!/bin/bash

# if [ -f srcs/.env ]; then
# 	exit 0
# fi
# Prompt for the decryption key
echo 
# read -sp "Enter decryption key:" DECRYPTION_KEY # uncomment
DECRYPTION_KEY="test123" # to be deleted0
# Decrypt the .env file
if [ -f srcs/.env.enc ]; then
	openssl enc -aes-256-cbc -d -salt -pbkdf2 -in srcs/.env.enc -out srcs/.env -k "$DECRYPTION_KEY"
	if [ $? -ne 0 ]; then
		echo "Error: Decryption failed."
		shred -u srcs/.env
		exit 1
	fi
else
	echo "Error: srcs/.env.enc file not found."
	exit 1
fi

# sleep 1 
# Load environment variables from .env file
export $(grep -v '^#' srcs/.env | xargs)

# Create secret files
echo "$MYSQL_ROOT_PASSWORD" > secrets/db_root_password.txt
echo "$MYSQL_PASSWORD" > secrets/db_password.txt
# echo "$WORDPRESS_ADMIN_PASSWORD" > secrets/wp_admin_password.txt
# echo "$WORDPRESS_USER_PASSWORD" > secrets/wp_user_password.txt

chmod 600 secrets/db_root_password.txt secrets/db_password.txt 
# Create credentials.txt file
cat <<EOF > secrets/credentials.txt
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
DB_HOST=$DB_HOST
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_PASSWORD=$MYSQL_PASSWORD
AUTH_KEY=$AUTH_KEY
SECURE_AUTH_KEY=$SECURE_AUTH_KEY
LOGGED_IN_KEY=$LOGGED_IN_KEY
NONCE_KEY=$NONCE_KEY
AUTH_SALT=$AUTH_SALT
SECURE_AUTH_SALT=$SECURE_AUTH_SALT
LOGGED_IN_SALT=$LOGGED_IN_SALT
NONCE_SALT=$NONCE_SALT
EOF
chmod 600 secrets/credentials.txt

echo -e "\nContent: \n" && tree ./
echo
# Clean up
# shred -u srcs/.env