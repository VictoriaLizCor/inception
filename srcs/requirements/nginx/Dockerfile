# Use Debian bullseye as the base image
FROM debian:bullseye

ARG DOMAIN_NAME
# Update package list and install Nginx and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx curl openssl  \
    && rm -rf /var/lib/apt/lists/*

RUN env
# Create directory for Nginx PID
RUN mkdir -p /run/nginx 
RUN set -e

# Copy Nginx configuration file
COPY ./conf/default.conf /etc/nginx/conf.d/default.conf
RUN cat /etc/nginx/conf.d/default.conf 
RUN rm /etc/nginx/sites-enabled/default

# Create directory for WordPress and set permissions
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy SSL certificates
COPY ./conf/ssl/fullchain.crt /etc/nginx/ssl/
COPY ./conf/ssl/privkey.key /etc/nginx/ssl/
# RUN mv var/www/html/index.nginx-debian.html /var/www/html/index.html
# Expose port 443 for HTTPS
EXPOSE 443


# Create a health check file
RUN echo -e "OK" > /var/www/html/healthcheck.html

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]