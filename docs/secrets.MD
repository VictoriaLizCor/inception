Docker itself does not provide a direct command to create a `credentials.txt` file from environment variables or secrets. However, you can achieve this by writing a script that reads the environment variables or Docker secrets and writes them to a `credentials.txt` file.

Here’s how you can do it:

1. **Create a script to generate `credentials.txt`:**
   - Create a script named `generate_credentials.sh` that reads the environment variables or Docker secrets and writes them to a `credentials.txt` file.

   ```sh
   #!/bin/sh

   # Read secrets from Docker secrets or environment variables
   DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password 2>/dev/null || echo $MYSQL_ROOT_PASSWORD)
   DB_PASSWORD=$(cat /run/secrets/db_password 2>/dev/null || echo $MYSQL_PASSWORD)
   WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password 2>/dev/null || echo $WP_ADMIN_PASSWORD)
   WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password 2>/dev/null || echo $WP_USER_PASSWORD)

   # Create credentials.txt file
   cat <<EOF > /path/to/credentials.txt
   MYSQL_ROOT_PASSWORD=$DB_ROOT_PASSWORD
   MYSQL_PASSWORD=$DB_PASSWORD
   WP_ADMIN_PASSWORD=$WP_ADMIN_PASSWORD
   WP_USER_PASSWORD=$WP_USER_PASSWORD
   EOF
   ```	

2. **Make the script executable:**
   - Ensure the script is executable by running:

   ```sh
   chmod +x generate_credentials.sh
   ```

3. **Run the script in your Docker container:**
   - You can run this script as part of your Docker container startup process. Modify your Docker Compose file to include the script execution.

   ```yaml
   version: '3.1'

   services:
     mariadb:
       image: mariadb:10.5
       environment:
         MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
         MYSQL_DATABASE: ${MYSQL_DATABASE}
         MYSQL_USER: ${MYSQL_USER}
         MYSQL_PASSWORD_FILE: /run/secrets/db_password
       secrets:
         - db_root_password
         - db_password
       command: ["sh", "-c", "/path/to/generate_credentials.sh && docker-entrypoint.sh mysqld"]

     wordpress:
       image: wordpress:5.7
       environment:
         WORDPRESS_DB_HOST: ${MYSQL_HOST}
         WORDPRESS_DB_NAME: ${WP_DATABASE}
         WORDPRESS_DB_USER: ${MYSQL_USER}
         WORDPRESS_DB_PASSWORD_FILE: /run/secrets/db_password
         WORDPRESS_ADMIN_PASSWORD_FILE: /run/secrets/wp_admin_password
         WORDPRESS_USER_PASSWORD_FILE: /run/secrets/wp_user_password
       secrets:
         - db_password
         - wp_admin_password
         - wp_user_password
       depends_on:
         - mariadb
       command: ["sh", "-c", "/path/to/generate_credentials.sh && docker-entrypoint.sh apache2-foreground"]

     nginx:
       image: nginx:1.21
       ports:
         - "443:443"
       volumes:
         - ./nginx.conf:/etc/nginx/nginx.conf:ro
         - ./certs:/etc/nginx/certs:ro
       depends_on:
         - wordpress

   secrets:
     db_root_password:
       external: true
     db_password:
       external: true
     wp_admin_password:
       external: true
     wp_user_password:
       external: true
   ```

4. **Ensure the script runs correctly:**
   - The script will read the secrets from the `/run/secrets` directory or fallback to environment variables if the secrets are not available. It will then write the credentials to the `credentials.txt` file.

By following these steps, you can create a `credentials.txt` file within your Docker container that contains the necessary credentials, securely managed through Docker secrets or environment variables.