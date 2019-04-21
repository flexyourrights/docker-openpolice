# docker-openpolice
This install process installs Open Police Complaints with Docker, Laravel, SurvLoop, Laradock, Nginx, MYSQL, and Phpmyadmin.

## Overview
Couldn't get my original attempt working with a Docker Compose configuration. Perhaps someone can help me, now that this install process is at least easier. Thanks!


## Install prerequisites

You will need:

* [Docker CE](https://docs.docker.com/engine/installation/)
* [Docker Compose](https://docs.docker.com/compose/install)
* Git

## How to use it

<h1 class="slBlueDark">How To Install OpenPolice with Laradock</h1>

<p>First, <a href="https://www.docker.com/get-started" target="_blank">install Docker</a> on Mac, Windows, or an online server. Then...</p>
<pre>
$ git clone https://github.com/laravel/laravel.git opc
$ cd opc
$ cp .env.example .env
$ nano .env
</pre>
<p>Change the database connection:</p>
<pre>
DB_HOST=mysql
DB_DATABASE=default
DB_USERNAME=default
</pre>

<p>Next, install and boot up Laradock.</p>
<pre>
$ git submodule add https://github.com/Laradock/laradock.git
$ cd laradock
$ cp env-example .env
$ docker-compose up -d nginx mysql phpmyadmin redis workspace
</pre>

<p>After Docker finishes booting up your containers, enter the mysql container with the root password, "root". This seems to fix things for the latest version of MYSQL.</p>
<pre>
$ docker-compose exec mysql bash
# mysql --user=root --password=root default
mysql> ALTER USER 'default'@'%' IDENTIFIED WITH mysql_native_password BY 'secret';
mysql> exit;
$ exit
</pre>

<p>At this point, you should be able to browse to <a href="http://localhost:8080" target="_blank">http://localhost:8080</a> for PhpMyAdmin.</p>
<pre>Server: mysql
Username: default
Password: secret
</pre>

<p>Finally, enter Laradock's workspace container to download and run the Open Police installation script.</p>
<pre>
$ docker-compose exec workspace bash
# cp https://raw.githubusercontent.com/flexyourrights/docker-openpolice/master/bin/openpolice-laradock-postinstall.sh ./
# chmod +x ./openpolice-laradock-postinstall.sh
# ./openpolice-laradock-postinstall.sh
# docker-compose exec workspace composer require flexyourrights/openpolice-website
</pre>

<p>If all has gone well, you'll be asked to create a master admin user account when you browse to <a href="http://localhost/" target="_blank">http://localhost/</a>.</p>




## Change configuration

