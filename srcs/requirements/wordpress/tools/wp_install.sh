#!/bin/bash
set -x
if [ -f /run/secrets/credentials ]; then
    while IFS='=' read -r key value; do
        if [[ ! $key =~ ^# && -n $key ]]; then
            export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
        else
            export "$key=$(echo "$value" | sed 's/^"\(.*\)"$/\1/')"
        fi
    done < /run/secrets/credentials
else
    echo "Error: /run/secrets/credentials file not found."
    exit 1
fi


# env > /credentials
# Load secrets
echo -e "##################################" 
# Ensure TABLE_PREFIX is set

env
# Substitute environment variables in wp-config.php template
# if ! envsubst < /wp-config.php.template > /var/www/html/wp-config.php; then
#     echo "Error: Failed to substitute environment variables in wp-config.php"
#     exit 1
# fi

# wget https://wordpress.org/latest.tar.gz
# tar -xzf latest.tar.D
# cp wordpress/wp-config-sample.php wordpress/wp-config.php
# pwd
## Change to the WordPress directory
cd /var/www/html
# echo "Contents of /var/www/html/wp-config.php:"
# cat /var/www/html/wp-config.php
# Wait for MariaDB to be ready
# echo "Waiting for MariaDB to be ready..."
echo -e "##################################" 
cat /run/secrets/credentials

# mysqladmin -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" status
# mysqladmin ping -h localhost -u"mysql" -p"${MYSQL_PASSWORD}"

echo -e "${MYSQL_HOST}"
mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD"

# Install WordPress
echo "Downloading WordPress..."

if wp core is-installed --allow-root; then
    echo "WordPress is already installed."
	wp core update --allow-root
else
	wp core download --allow-root
	mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
	# echo "Configuring WordPress..."
	wp config set --allow-root DB_NAME "$MYSQL_DATABASE"
	wp config set --allow-root DB_USER "$MYSQL_USER"
	wp config set --allow-root DB_PASSWORD "$MYSQL_PASSWORD"
	wp config set --allow-root DB_HOST "$MYSQL_HOST"
	wp config set --allow-root AUTH_KEY "${AUTH_KEY}"
	wp config set --allow-root SECURE_AUTH_KEY "${SECURE_AUTH_KEY}"
	wp config set --allow-root LOGGED_IN_KEY "${LOGGED_IN_KEY}"
	wp config set --allow-root NONCE_KEY "${NONCE_KEY}"
	wp config set --allow-root AUTH_SALT "${AUTH_SALT}"
	wp config set --allow-root SECURE_AUTH_SALT "${SECURE_AUTH_SALT}"
	wp config set --allow-root LOGGED_IN_SALT "${LOGGED_IN_SALT}"
	wp config set --allow-root NONCE_SALT "${NONCE_SALT}"
fi
	
echo -e "##################################"
echo "Installing WordPress..."
echo -e "##################################"

if ! wp core install --url="https://$DOMAIN_NAME" --title="$WORDPRESS_TITLE" --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" --admin_email="$WORDPRESS_ADMIN_EMAIL" --allow-root --debug; then
    echo "Error: Failed to install WordPress"
    exit 1
fi

echo "WP was successfully installed"
echo -e "##################################"
# Create additional WordPress user if it does not exist
if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
    if ! wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" --user_pass="$WORDPRESS_USER_PASSWORD" --role="subscriber" --allow-root; then
        echo "Error: Failed to create additional WordPress user"
        exit 1
	fi
	find /var/www/html -type d -exec chmod 755 {} \; && \
	find /var/www/html -type f -exec chmod 644 {} \;
	# wp config set ALLOW_UNFILTERED_UPLOADS true --raw --allow-root

	# echo "Replacing 'http://example.com' by 'https://example.com' within the WordPress database"
	wp search-replace "http://$DOMAIN_NAME" "https://$DOMAIN_NAME" --allow-root
	wp option update blog_public 0 --allow-root # Restrict access from search engines
	wp rewrite structure '/%postname%/' --allow-root # Set permalink structure

	# Delete unnecessary plugins and themes
	wp plugin delete hello --allow-root
	if wp theme is-installed twentytwentythree --allow-root; then
		wp theme delete twentytwentythree --allow-root
	fi
	if wp theme is-installed twentytwentyfour --allow-root; then
		wp theme delete twentytwentyfour --allow-root
	fi
	# if wp theme is-installed twentytwentyfive --allow-root; then
	# 	wp theme delete twentytwentyfive --allow-root
	# fi
	
	wp post delete 1 --force --allow-root
	
	# Create a new post with a Bootstrap carousel
	POST_CONTENT='
	<div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
	<ol class="carousel-indicators">
		<li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
		<li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
		<li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
		<li data-target="#carouselExampleIndicators" data-slide-to="3"></li>
	</ol>
	<div class="carousel-inner">
		<div class="carousel-item active">
		<img class="d-block w-100" src="https://lh3.googleusercontent.com/pw/AP1GczP4OpTlbcoBw_KcWgqDnnJoMvu4OAEaCDZHxvuD39qIw6yt3pD9sNaR1eVWxdOoVUIdQdFjFUR3ubmFCNg2Hq75MF-1WeRH1KsqrhIyM2iQdDlyPiH78NsGDjZn9ddwRb4ePKEpv0i93KtBNBcM5b0o=w1280-h960-s-no" alt="First slide">
		</div>
		<div class="carousel-item">
		<img class="d-block w-100" src="https://lh3.googleusercontent.com/pw/AP1GczObZlBw_vN4iwt1wDwLRsDhx-wrBvvCZeLoqyTFIro27FmrvhYbbWSEfQf7OIwIpdYLH0EW4S3z6BDk4CJA4UsMNF5OAThvuCCVDkpX81kpzy7o-xxc30wS2h6O_U4cS8hPNDWsqFw7McCFAFv0AEwk=w2057-h1157-s-no?authuser=0" alt="Second slide">
		</div>
		<div class="carousel-item">
		<img class="d-block w-100" src="https://lh3.googleusercontent.com/pw/AP1GczOko5QsdINEiRAZmIy8ahh0TbZCeglqhtWGGt8Z7Ksg6Y8DNu63EtGXM4ycak6-qHJuqDMEH3uPue_ZKoj_iXvKjSzsrhnWLKxG5b7dYLHk3VbhYFHtS0qrTcgkuCbSwwzy17gQHoS-kmM0hkH1cwah=w2057-h1157-s-no?authuser=0" alt="Third slide">
		</div>
		<div class="carousel-item">
		<img class="d-block w-100" src="https://lh3.googleusercontent.com/pw/AP1GczPAH01u7jk7r1Od0KbK0fr3pPWjpOY31wdHhy1l50OSDCpNpfOsIO29DK5-zlJrNeLdRYXFLpWmQH85GBu--vDH0vHh0eqAPCLZZ6vQ2h44LnzC18CV__C1Kvv7AaiLESvhp--b8AAUWWsM8A9RXucC=w1152-h864-s-no" alt="Fourth slide">
		</div>
	</div>
	<a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
		<span class="carousel-control-prev-icon" aria-hidden="true"></span>
		<span class="sr-only">Previous</span>
	</a>
	<a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
		<span class="carousel-control-next-icon" aria-hidden="true"></span>
		<span class="sr-only">Next</span>
	</a>
	</div>
	'
	#wp theme search artly --allow-root
	wp theme install yuki-reverie-blog --activate --allow-root
	# wp theme install artly --activate --allow-root
	# wp theme install hey  --activate --allow-root
	 
	# Install necessary plugins
	wp plugin install wp-super-cache --activate --allow-root
	wp plugin install simple-local-avatars --activate --allow-root
	THEME=$(wp theme list --status=active --field=name --allow-root)
	# Enqueue Bootstrap in the theme
	echo "function enqueue_bootstrap() {
		wp_enqueue_style('bootstrap-css', 'https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css');
		wp_enqueue_script('bootstrap-js', 'https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js', array('jquery'), null, true);
	}
	add_action('wp_enqueue_scripts', 'enqueue_bootstrap');" >> /var/www/html/wp-content/themes/$THEME/functions.php

	# Set user profile picture
	USER_ID=$(wp user get $WORDPRESS_USER --field=ID --allow-root)
	PROFILE_PICTURE_URL="https://lh3.googleusercontent.com/pw/AP1GczPpPxZZU408-rvu_8ZWeyoeDqMbl4gytgAfsJ5lF3D9Qkmkk5kUDFtfubHQuJl65co95Ii92ur-9UuVWUVDZmTH576-FGB5FARVVEaRDS5f3vXrsYYwm7x1Vz_ifmncflkf0qr07NMsZuQOnoB-iCRH=w512-h512-s-no?authuser=0"

	# Download the profile picture
	curl -o /tmp/tmp.jpg "$PROFILE_PICTURE_URL"
	convert /tmp/tmp.jpg -resize 150x150 /tmp/profile-picture.jpg
	# Upload the profile picture to WordPress
	ATTACHMENT_ID=$(wp media import /tmp/profile-picture.jpg --user=$USER_ID --porcelain --allow-root)
	# Set the profile picture for the user
	wp user meta update $USER_ID simple_local_avatar $ATTACHMENT_ID --allow-root
	# Retrieve the avatar URL
	AVATAR_URL=$(wp user meta get $USER_ID simple_local_avatar --allow-root)
	# Add avatar to the beginning of the post content
	# POST_CONTENT='<img src="'$AVATAR_URL'" alt="User Avatar" />'"\n$POST_CONTENT"
	# Clean up
	rm -rf /tmp/*.jpg
	echo "Profile picture set for user ID $USER_ID"

	wp term create category Blog --allow-root
	BLOG=$(wp term list category --name=Blog --field=term_id --allow-root)
	POST_ID=$(wp post create --post_title="This is my Hometown" --post_status=publish --post_content="$POST_CONTENT" --post_author="$USER_ID" --post_category="$BLOG" --allow-root --porcelain) --post_thumbnail="$ATTACHMENT_ID"


	# Find the ID of the "Sample Page"
	SAMPLE_PAGE_ID=$(wp post list --post_type=page --post_status=publish --field=ID --title="Sample Page" --allow-root)

	# Update the "Sample Page" to "Login" and set up a redirect to the login page
	wp post update $SAMPLE_PAGE_ID --post_title="Login" --post_name="login" --post_content='<script type="text/javascript">window.location.href="https://lilizarr.42.fr/wp-login.php";</script>' --allow-root
fi
echo "WordPress setup completed successfully!"

# Set correct permissions for directories and files
# chown www-data:www-data /var/www/html/wp-content/wp-cache-config.php
# chmod 664 /var/www/html/wp-content/wp-cache-config.php
# rm /credentials
php-fpm7.4 -F



# # Create a custom plugin to redirect emails
# cat <<EOL > /var/www/html/wp-content/plugins/email-redirect/email-redirect.php
# <?php
# /*
# Plugin Name: Email Redirect
# Description: Redirect all outgoing emails to a specified email address.
# Version: 1.0
# Author: $WORDPRESS_USER
# */

# add_filter('wp_mail', 'redirect_all_emails');

# function redirect_all_emails(\$args) {
#     \$args['to'] = '$MYSQL_EMAIL';
#     return \$args;
# }
# EOL

# # Activate the custom plugin
# wp plugin activate email-redirect --allow-root