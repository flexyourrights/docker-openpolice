#!/bin/bash
set -x
# ******* Running OpenPolice Laradock Intaller *******

#docker-compose exec --user root app chown -R www:www ./

cp .env.example .env
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=mysql/g' .env
sed -i 's/DB_DATABASE=homestead/DB_DATABASE=default/g' .env
sed -i 's/DB_USERNAME=homestead/DB_USERNAME=default/g' .env

# Laravel basic preparations
composer install
php artisan key:generate
php artisan make:auth

# Install SurvLoop & OpenPolice
composer require flexyourrights/openpolice

# Avoid error message from recent Laravel version
cp /var/www/vendor/wikiworldorder/survloop/src/Controllers/Middleware/routes-api.php /var/www/routes/api.php
cp /var/www/vendor/wikiworldorder/survloop/src/Controllers/Middleware/routes-web.php /var/www/routes/web.php

composer dump-autoload
php artisan optimize

# Install SurvLoop & OpenPolice service providers
#cp config/app.php config/app.bak.php
#sed -i 's/App\\Providers\\RouteServiceProvider::class,/App\\Providers\\RouteServiceProvider::class,\n\n        OpenPolice\\OpenPoliceServiceProvider::class,\n\n        SurvLoop\\SurvLoopServiceProvider::class,/g' config/app.php
#sed -i 's/Illuminate\\Support\\Facades\\View::class,/Illuminate\\Support\\Facades\\View::class,\n\n        "OpenPolice" \=\> FlexYourRights\\OpenPolice\\OpenPoliceFacade::class,\n\n        "SurvLoop" \=\> WikiWorldOrder\\SurvLoop\\SurvLoopFacade::class,/g' config/app.php

# Install SurvLoop user model
#cp config/auth.php config/auth.bak.php
sed -i 's/App\\User::class/App\\Models\\User::class/g' config/auth.php
cp vendor/wikiworldorder/survloop/src/Models/User.php app/User.php
sed -i 's/namespace App\\Models;/namespace App;/g' app/User.php

#sed -i 's/"App\\": "app\/"/"App\\": "app\/",\n\n        "SurvLoop\\": "vendor\/wikiworldorder\/survloop\/src\/",\n\n        "OpenPolice\\": "vendor\/flexyourrights\/openpolice\/src\/"/g' composer.json

# Clear caches for good measure, then push copies of vendor files
echo "0" | php artisan vendor:publish --force

# Migrate database designs, and seed with data
php artisan migrate

php artisan optimize
composer dump-autoload

php artisan db:seed --class=SurvLoopSeeder
php artisan db:seed --class=ZipCodeSeeder
php artisan db:seed --class=OpenPoliceSeeder
php artisan db:seed --class=OpenPoliceDeptSeeder

php artisan optimize
composer dump-autoload
