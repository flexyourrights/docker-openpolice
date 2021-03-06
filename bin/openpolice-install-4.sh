#!/bin/bash
set -x
# ******* Running OpenPolice Intaller ******* Act 4 ******* Initialize Laravel and Open Police Complaints

#docker-compose exec --user root app chown -R www:www ./

docker-compose exec app php artisan key:generate
docker-compose exec app php artisan make:auth

#docker-compose exec app composer require flexyourrights/openpolice

#docker-compose exec app cp /var/www/config/app.php /var/www/config/app.bak.php
#docker-compose exec app sed -i 's/App\\Providers\\RouteServiceProvider::class,/App\\Providers\\RouteServiceProvider::class,\n\n        OpenPolice\\OpenPoliceServiceProvider::class,\n\n        SurvLoop\\SurvLoopServiceProvider::class,/g' /var/www/config/app.php
#docker-compose exec app sed -i 's/Illuminate\\Support\\Facades\\View::class,/Illuminate\\Support\\Facades\\View::class,\n\n       "OpenPolice" \=\> FlexYourRights\\OpenPolice\\OpenPoliceFacade::class,\n\n       "SurvLoop" \=\> RockHopSoft\\SurvLoop\\SurvLoopFacade::class,/g' /var/www/config/app.php

#docker-compose exec app cp /var/www/config/auth.php /var/www/config/auth.bak.php
#docker-compose exec app sed -i 's/App\\User::class/App\\Models\\User::class/g' /var/www/config/auth.php

#docker-compose exec app cp /var/www/vendor/rockhopsoft/survloop/src/Models/User.php /var/www/app/User.php
#docker-compose exec app sed -i 's/namespace App\\Models;/namespace App;/g' /var/www/app/User.php

#docker-compose exec app cp /var/www/vendor/rockhopsoft/survloop/src/Controllers/Middleware/routes-api.php /var/www/routes/api.php

docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan route:clear
docker-compose exec app composer dump-autoload
docker-compose exec app php artisan vendor:publish --force

docker-compose exec app php artisan migrate
docker-compose exec app php artisan db:seed --class=SurvLoopSeeder
docker-compose exec app php artisan db:seed --class=ZipCodeSeeder
docker-compose exec app php artisan db:seed --class=OpenPoliceSeeder
docker-compose exec app php artisan db:seed --class=OpenPoliceDeptSeeder

docker-compose exec app php artisan optimize
docker-compose exec app composer dump-autoload
