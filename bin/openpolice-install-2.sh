#!/bin/bash
set -x
# ******* Running OpenPolice Intaller ******* Act 2 ******* Copy Laravel package, docker composer, and prep environment config
codename=bionic
dockerComposeVersion=1.23.2

sudo apt update
sudo apt-get upgrade

git clone https://github.com/laravel/laravel.git ~/openpolice
cd ~/openpolice
cp -rf /usr/local/lib/docker-openpolice/{Dockerfile,docker-compose.yml,.env,php,nginx,mysql} ./

sudo chown -R $USER:$USER ~/openpolice
cp /usr/local/lib/docker-openpolice/.env ~/openpolice/.env

# Installing Docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $codename stable"
sudo apt update
sudo apt install docker-ce
sudo usermod -aG docker ${USER}
sudo curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Login again to apply docker group permissions
su - ${USER}
