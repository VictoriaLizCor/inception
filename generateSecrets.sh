#!/binsh

# Prompt for the decryption key
echo "Enter decryption key:"
read -s DECRYPTION_KEY

# Decrypt the .env file
if [ -f srcs/.env.enc ]; then
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -in srcs/.env.enc -out srcs/.env -k "$DECRYPTION_KEY"
else
    echo "Error: srcs/.env.enc file not found."
    exit 1
fi

# sleep 1 
# Load environment variables from .env file
set -a
[ -f srcs/.env ] && . srcs/.env
set +a

# Create secret files
echo "$MYSQL_ROOT_PASSWORD" > secrets/db_root_password.txt
echo "$MYSQL_PASSWORD" > secrets/db_password.txt
echo "$WP_ADMIN_PASSWORD" > secrets/wp_admin_password.txt
echo "$WP_USER_PASSWORD" > secrets/wp_user_password.txt

# Create credentials.txt file
cat <<EOF > secrets/credentials.txt
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
MYSQL_PASSWORD=$MYSQL_PASSWORD
WP_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD
WP_USER_PASSWORD=$WP_USER_PASSWORD
EOF
env 
tree ./

# Clean up
# rm srcs/.env