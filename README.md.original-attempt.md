# docker-openpolice
Docker Compose configuration for Open Police Complaints ^0.1 running PHP 7.3 with Nginx, PHP-FPM, PostgreSQL 11.2 and Composer.

## Overview

Docker Compose configuration for openpolice ^0.1 running PHP 7.3 with Nginx, PHP-FPM, PostgreSQL 11.2 and Composer. 
It exposes 4 services:

* web (Nginx)
* php (PHP 7.3 with PHP-FPM)
* db (PostgreSQL 11.2)
* composer
* openpolice

The PHP image comes with the most commonly used extensions and is configured with xdebug.
The UUID extension for PostgreSQL has been added.
Nginx default configuration is set up for Symfony 4 and serves the working directory.
Composer is run at boot time and will automatically install the vendors.

## Install prerequisites

You will need:

* [Docker CE](https://docs.docker.com/engine/installation/)
* [Docker Compose](https://docs.docker.com/compose/install)
* Git (optional)

## How to use it

<h1 class="slBlueDark">How To Install OpenPolice with Docker on a Mac</h1>
<p><a href="https://id.docker.com/login/" target="_blank">Create an account on Docker</a>. <a href="https://download.docker.com/mac/stable/Docker.dmg" target="_blank">Download Docker CE for Mac</a>. Install it, and run it. Open your Mac Terminal, pull and run the Docker repository. Then list the running containers:</p>
<pre>$ docker pull flexyourrights/openpolice:0.1
$ docker run flexyourrights/openpolice:0.1
$ docker ps
$ </pre>
<p>If you like, replace the auto-name with something referred to in later steps, e.g.:</p>
<pre>$ docker rename heuristic_joliot openpolice</pre>





<h1 class="slBlueDark">How To Rebuild this OpenPolice Docker Installation from Scratch (on Mac)</h1>
<p>First, install Docker for Mac, and sign into it. Then hop into the terminal...</p>
<pre>
$ git clone https://github.com/laravel/laravel.git opc
$ git clone https://github.com/flexyourrights/docker-openpolice.git opc/docker-openpolice
$ cd opc
$ cp docker-openpolice/{Dockerfile,docker-compose.yml} ./
$ cp .env.example .env
$ cp docker-openpolice/.env .env
$ docker run --rm -v $(pwd):/app composer install
$ docker-compose up -d
$ chmod +x docker-openpolice/bin/*.sh
$ docker-openpolice/bin/openpolice-install-4.sh
</pre>

<p>Need to clean your slate and try again?..</p>
<pre>$ docker-compose down
$ docker system prune -a
$ docker rmi $(docker images -a -q)</pre>
<p>Endless restarting error message?.. maybe try,</p>
<pre>$ docker update --restart=unless-stopped app</pre>





<h1 class="slBlueDark">How To Rebuild this OpenPolice Docker Installation from Scratch (on Digital Ocean)</h1>
<p>This process runs a variety of <a href="https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose" target="_blank">Digital Ocean's layered tutorials</a>. I don't understand all of it yet, so will leave the explanations to their superb articles. This variation also adds SurvLoop and OpenPolice structures.</p>
<p>After starting up a new <b class="red">Ubuntu 18.04</b> Droplet — I couldn't pull this off with less than <span class="red">2GB RAM</span> — connect it with the root account and your SSH key. The first install script will create a non-root user, e.g. <span class="red">survuser</span>. Be sure to create and save a copy of a strong password, which you'll need handy throughout this install:</p>
<pre>$ git clone https://github.com/flexyourrights/docker-openpolice.git /usr/local/lib/docker-openpolice
$ chmod +x /usr/local/lib/docker-openpolice/bin/*.sh
$ /usr/local/lib/docker-openpolice/bin/openpolice-install-1.sh <span class="red">survuser</span>
$ exit
# ssh <span class="red">survuser</span>@<span class="red">YOUR.SERVER.IP</span>
</pre>
<p>Exit to logout as root, and log back in as <span class="red">survuser</span>. Your key should work, and you should have sudo power. During these installs you can accept all defaults, but I do opt for the latest manufacturer's version of the OpenSSH package.</p>

<h3 class="slBlueDark">Now logged in as a non-root user</h3>
<pre>$ sudo chmod +x /usr/local/lib/docker-openpolice/bin/*.sh
$ bash /usr/local/lib/docker-openpolice/bin/openpolice-install-2.sh
</pre>
<p>Build and boot Docker Containers...</p>
<pre>$ bash /usr/local/lib/docker-openpolice/bin/openpolice-install-3.sh
</pre>
<p>Update the .env file for your system with a database password you can create now. (Also a great time to change the user and database names, if you like.)</p>
<pre>$ cd ~/openpolice
$ docker-compose exec app nano .env
</pre>
<pre>DB_DATABASE=openpolice
DB_USERNAME=openpoliceuser
DB_PASSWORD=<span class="red">openpoliceuserpassword</span></pre>

<h4>Create Database & Permissions</h4>
<p>If you haven't already, enter the database container, then the MYSQL command line, using the strong database user password you entered in the .env file.</p>
<pre>$ cd ~/openpolice
$ docker-compose exec db bash
root@9472354969ea:/# mysql -u root -p</pre>
<p>Next, give your <span class="red">openpoliceuser</span> permission to your new database.</p>
<pre>mysql> GRANT ALL ON <span class="red">openpolice</span>.* TO '<span class="red">openpoliceuser</span>'@'%' IDENTIFIED BY '<span class="red">openpoliceuserpassword</span>';
mysql> FLUSH PRIVILEGES;
mysql> EXIT;
root@9472354969ea:/# exit</pre>

<h4>Tweak Composer.json</h4>
<pre>$ cd ~/openpolice
$ docker-compose exec app nano composer.json</pre>
<p>Update `composer.json` to add requirements and an easier SurvLoop and OpenPolice reference:</p>
<pre>...
"autoload": {
    ...
    "psr-4": {
        ...
        "SurvLoop\\": "vendor/rockhopsoft/survloop/src/",
        "OpenPolice\\": "vendor/flexyourrights/openpolice/src/",
    }
    ...
},
...</pre>

<h4>Fill Database</h4>
<p>Once your database is created, and login info linked with Laravel, we can install database...</p>
<pre>$ bash /usr/local/lib/docker-openpolice/bin/openpolice-install-4.sh</pre>
<p>Which provider or tag's files would you like to publish? <b>0</b></p>


## Change configuration

