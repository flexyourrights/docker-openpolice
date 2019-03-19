#!/bin/bash
set -x
# ******* Running OpenPolice Intaller ******* Act 1 ******* Prepping fresh Ubuntu 18.04 server with a non-root user

# Create swap file, important for servers with little memory
/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1

# Create non-root user
adduser $1
usermod -aG sudo $1
ufw allow OpenSSH
ufw enable
rsync --archive --chown=$1:$1 ~/.ssh /home/$1
#chmod +x $1:$1 /usr/local/lib/docker-openpolice/bin/*.sh
