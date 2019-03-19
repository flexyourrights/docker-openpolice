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
#RUN mkdir -p /var/www/database/seeds
#RUN chown -R www:www /var/www/database/seeds
RUN composer require flexyourrights/openpolice
RUN composer update

# Set directory permissions and overrides needed by SurvLoop
RUN cp /var/www/vendor/wikiworldorder/survloop/src/Models/User.php /var/www/app/User.php
#RUN chmod -R gu+w www-data:33 ./app/Models
#RUN chmod -R gu+w www-data:33 ./app/User.php
#RUN chmod -R gu+w www-data:33 ./database
#RUN chmod -R gu+w www-data:33 ./storage/app

RUN php artisan key:generate
RUN php artisan make:auth
RUN php artisan vendor:publish
RUN php artisan migrate
RUN php artisan optimize
RUN composer dump-autoload
RUN php artisan db:seed --class=SurvLoopSeeder
RUN php artisan db:seed --class=ZipCodeSeeder
RUN php artisan db:seed --class=OpenPoliceSeeder
RUN php artisan db:seed --class=OpenPoliceDeptSeeder

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
