#!/bin/bash
set -x
# ******* Running OpenPolice Laradock Intaller *******

#docker-compose exec --user root app chown -R www:www ./

docker-compose exec workspace php artisan key:generate

docker-compose exec workspace php artisan make:auth
docker-compose exec workspace composer require flexyourrights/openpolice

docker-compose exec workspace cp /var/www/config/app.php /var/www/config/app.bak.php
docker-compose exec workspace sed -i 's/App\\Providers\\RouteServiceProvider::class,/App\\Providers\\RouteServiceProvider::class,\n\n        OpenPolice\\OpenPoliceServiceProvider::class,\n\n        SurvLoop\\SurvLoopServiceProvider::class,/g' /var/www/config/app.php
docker-compose exec workspace sed -i 's/Illuminate\\Support\\Facades\\View::class,/Illuminate\\Support\\Facades\\View::class,\n\n       "OpenPolice" \=\> FlexYourRights\\OpenPolice\\OpenPoliceFacade::class,\n\n       "SurvLoop" \=\> WikiWorldOrder\\SurvLoop\\SurvLoopFacade::class,/g' /var/www/config/app.php

docker-compose exec workspace cp /var/www/config/auth.php /var/www/config/auth.bak.php
docker-compose exec workspace sed -i 's/App\\User::class/App\\Models\\User::class/g' /var/www/config/auth.php

docker-compose exec workspace cp /var/www/vendor/wikiworldorder/survloop/src/Models/User.php /var/www/app/User.php
docker-compose exec workspace sed -i 's/namespace App\\Models;/namespace App;/g' /var/www/app/User.php

docker-compose exec workspace cp /var/www/vendor/wikiworldorder/survloop/src/Controllers/Middleware/routes-api.php /var/www/routes/api.php

docker-compose exec workspace php artisan config:clear
docker-compose exec workspace php artisan cache:clear
docker-compose exec workspace php artisan route:clear
docker-compose exec workspace composer dump-autoload
docker-compose exec workspace php artisan vendor:publish --force

docker-compose exec workspace php artisan migrate
docker-compose exec workspace php artisan db:seed --class=SurvLoopSeeder
docker-compose exec workspace php artisan db:seed --class=ZipCodeSeeder
docker-compose exec workspace php artisan db:seed --class=OpenPoliceSeeder
docker-compose exec workspace php artisan db:seed --class=OpenPoliceDeptSeeder

docker-compose exec workspace php artisan optimize
docker-compose exec workspace composer dump-autoload
