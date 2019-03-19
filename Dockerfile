FROM php:7.3-fpm

# Copy composer.lock and composer.json
COPY composer.json /var/www/
#COPY composer.lock /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    mysql-client \
    libpng-dev \
    libzip-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    nano \
    unzip \
    wget \
    git \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Install Open Police Complaints and SurvLoop
RUN cd /var/www
RUN php artisan key:generate
RUN php artisan make:auth
#RUN mkdir -p /var/www/database/seeds
#RUN chown -R www:www /var/www/database/seeds
RUN composer require flexyourrights/openpolice
RUN composer update
RUN composer install
CMD php artisan serve --host=0.0.0.0 --port=8000

USER root

# Copy existing application directory contents
ADD vendor/wikiworldorder /var/www/vendor
ADD vendor/flexyourrights /var/www/vendor

# Set directory permissions and overrides needed by SurvLoop?
#RUN chmod -R gu+w www-data:33 ./app/Models
#RUN chmod -R gu+w www-data:33 ./app/User.php
#RUN chmod -R gu+w www-data:33 ./database
#RUN chmod -R gu+w www-data:33 ./storage/app

RUN php artisan config:clear
RUN php artisan cache:clear
RUN php artisan vendor:publish

# Change current user to www

USER www


# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
