#!/bin/bash
set -x
# ******* Running OpenPolice Intaller ******* Act 4 ******* Initialize Laravel and Open Police Complaints

docker-compose exec app ls -l /var/www/vendor/

: '
docker-compose exec app cp /var/www/vendor/wikiworldorder/survloop/src/Models/User.php /var/www/app/User.php

docker-compose exec app php artisan migrate
docker-compose exec app php artisan optimize
docker-compose exec app composer dump-autoload
docker-compose exec app php artisan db:seed --class=SurvLoopSeeder
docker-compose exec app php artisan db:seed --class=ZipCodeSeeder
docker-compose exec app php artisan db:seed --class=OpenPoliceSeeder
docker-compose exec app php artisan db:seed --class=OpenPoliceDeptSeeder
'