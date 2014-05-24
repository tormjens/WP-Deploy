#!/bin/bash

INSTALL="$1"
DIR="/var/www/sites/$INSTALL"
WWW="/var/www/sites/$INSTALL/www"

killall -u $INSTALL
userdel -f $INSTALL
rm -r $WWW
rm -r $DIR

echo "Account $install has been terminated"