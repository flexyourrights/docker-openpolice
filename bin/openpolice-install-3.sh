#!/bin/bash
set -x
# ******* Running OpenPolice Intaller ******* Act 3 ******* Initialize Laravel and Open Police Complaints
cd ~/openpolice
docker run --rm -v $(pwd):/app composer install
docker-compose up -d
docker ps
