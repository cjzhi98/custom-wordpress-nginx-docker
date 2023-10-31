FROM php:8.1-fpm

# Install required PHP extensions
RUN docker-php-ext-install mysqli pdo_mysql

# Copy WordPress files into container
COPY ./wordpress /var/www/html

# Set ownership and permissions for WordPress files
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose port 80 for Nginx
EXPOSE 80