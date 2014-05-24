#!/bin/bash

INSTALL="$1"
DIR="/var/www/sites/$INSTALL"
WWW="/var/www/sites/$INSTALL/www"

useradd -d $DIR $INSTALL
mkdir $DIR
mkdir $WWW
chown $INSTALL $DIR
chown $INSTALL $WWW

echo "User $INSTALL was created"