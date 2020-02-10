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
    sudo \
    curl

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy existing application directory contents, before composing more
COPY . /var/www

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

RUN composer update

ENTRYPOINT ["php", "artisan"]

RUN php artisan make:auth

RUN composer require flexyourrights/openpolice

RUN cp /var/www/config/app.php /var/www/config/app.bak.php
RUN sed -i 's/App\\Providers\\RouteServiceProvider::class,/App\\Providers\\RouteServiceProvider::class,\n\n        OpenPolice\\OpenPoliceServiceProvider::class,\n\n        SurvLoop\\SurvLoopServiceProvider::class,/g' /var/www/config/app.php
RUN sed -i 's/Illuminate\\Support\\Facades\\View::class,/Illuminate\\Support\\Facades\\View::class,\n\n       "OpenPolice" \=\> FlexYourRights\\OpenPolice\\OpenPoliceFacade::class,\n\n       "SurvLoop" \=\> RockHopSoft\\SurvLoop\\SurvLoopFacade::class,/g' /var/www/config/app.php

RUN php artisan config:clear
RUN php artisan cache:clear
RUN composer dump-autoload
RUN php artisan vendor:publish --force

RUN cp /var/www/config/auth.php /var/www/config/auth.bak.php
RUN sed -i 's/App\\User::class/App\\Models\\User::class/g' /var/www/config/auth.php

RUN cp /var/www/vendor/rockhopsoft/survloop/src/Models/User.php /var/www/app/User.php
RUN sed -i 's/namespace App\\Models;/namespace App;/g' /var/www/app/User.php

RUN cp /var/www/vendor/rockhopsoft/survloop/src/Controllers/Middleware/routes-api.php /var/www/routes/api.php


RUN chown -R www-data:33 /var/www/storage
RUN chown -R www-data:33 /var/www/bootstrap/cache

RUN ls -l /var/www/database/seeds

RUN php artisan optimize
RUN composer dump-autoload

# Expose port 9000 and start php-fpm server
#CMD php artisan serve --host=0.0.0.0 --port=9000
EXPOSE 9000
CMD ["php-fpm"]

USER www
