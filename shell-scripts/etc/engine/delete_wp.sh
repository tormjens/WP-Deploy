#!/bin/bash

# information about install from the command line
installname="$1"


# validate that all parameteres are filled out
if [ $# != 1 ]
then
        echo "Usage: `basename $0` installname blog_title admin_email admin_passw"
        exit 1 
fi

# directories
dir="/var/www/sites/$installname"
www="/var/www/sites/$installname/www"

# database stuff
db_name="wp_$installname"
db_user="$db_name"
db_password=`date |md5sum |cut -c '1-12'`

# The repo for WordPress
REPO="https://github.com/WordPress/WordPress.git"

if [ -d "$www" ]; then
        if [ "$(ls -A $www)" ]; then

                echo "Deleting content in folder for: $installname"
                /bin/rm -R $www/*

                if [ -d "$www/.git" ]; then
                        echo "Deleting .git folder"
                        /bin/rm -R "$www/.git"
                fi

                # Create the database
                echo "Deleting database: $db_name";
                /usr/bin/mysql -u "root" "-pG01374k^Y3{H{7s" -e "DROP DATABASE IF EXISTS $db_name;"
                echo "Deleting database user: $db_user";
                /usr/bin/mysql -u "root" "-pG01374k^Y3{H{7s" -e "DROP USER '$db_user'@'localhost';"
        else
                echo "No WordPress present in this folder"
                exit 1
        fi
fi
