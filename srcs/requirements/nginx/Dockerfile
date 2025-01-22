# Use Debian bullseye as the base image
FROM debian:bullseye

# Update package list and install Nginx and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx curl openssl certbot \
    && rm -rf /var/lib/apt/lists/*

RUN env
# Create directory for Nginx PID
RUN mkdir -p /run/nginx 


# Copy Nginx configuration file
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default

# Create directory for WordPress and set permissions
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy SSL certificates

COPY ./conf/ssl/fullchain.crt /var/www/htm/
COPY ./conf/ssl/privkey.key /var/www/htm/
# Expose port 443 for HTTPS
EXPOSE 443

# Create a health check file
RUN echo -e "OK" > /var/www/html/healthcheck.html

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]