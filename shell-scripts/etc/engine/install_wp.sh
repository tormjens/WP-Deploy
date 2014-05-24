#!/bin/bash

# information about install from the command line
installname="$1"
admin_email="$2"
admin_pass="$3"

# validate that all parameteres are filled out
if [ $# != 3 ]
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

# How to get WordPress
method="wp" # wp or git

if [ -d "$www" ]; then

        if [ $method = "git" ]; then
                echo "Cloning WordPress"

                git clone $REPO $www --quiet

                success=$?

                if [[ $success -eq 0 ]];
                then
                        echo "Repository successfully cloned."
                else
                        echo "Something went wrong while cloning WordPress. Process aborted."
                        exit 1
                fi

        else

                if test -f /tmp/latest.tar.gz
                then
                        echo "Latest WordPress is already downloaded. No need for a new one."
                else
                        echo "Downloading the latest version of WordPress."
                        cd /tmp/ && wget "http://wordpress.org/latest.tar.gz"
                fi

                /bin/tar -C $www -zxf /tmp/latest.tar.gz --strip-components=1

        fi

        # fix ownership
        chown nobody: $www -R

        # create config file
        /bin/mv $www/wp-config-sample.php $www/wp-config.php

        # insert values
        /bin/sed -i "s/database_name_here/$db_name/g" $www/wp-config.php
        /bin/sed -i "s/username_here/$db_user/g" $www/wp-config.php
        /bin/sed -i "s/password_here/$db_password/g" $www/wp-config.php

        # Get the salts and keys
        /bin/grep -A50 'table_prefix' $www/wp-config.php > /tmp/wp-temp-config
        /bin/sed -i '/**#@/,/$p/d' $www/wp-config.php
        /usr/bin/lynx --dump -width 200 https://api.wordpress.org/secret-key/1.1/salt/ >> $www/wp-config.php
        /bin/cat /tmp/wp-temp-config >> $www/wp-config.php && rm /tmp/wp-temp-config -f

        # Create the database
        echo "Creating database: $db_name"
        /usr/bin/mysql -u "root" "-pG01374k^Y3{H{7s" -e "DROP DATABASE IF EXISTS $db_name;"
        /usr/bin/mysql -u "root" "-pG01374k^Y3{H{7s" -e "CREATE DATABASE $db_name"
        /usr/bin/mysql -u "root" "-pG01374k^Y3{H{7s" -e "GRANT ALL PRIVILEGES ON $db_name.* to '"$db_user"'@'localhost' IDENTIFIED BY '"$db_password"';"


        # Populate the database
        /usr/bin/php -r "
        include '"$www"/wp-admin/install.php';
        wp_install('"$installname" WordPress Blog', '"$installname"', '"$admin_email"', 1, '', '"$admin_pass"');" > /dev/null 2>&1

        echo "Successfully created new WordPress install: $installname"

fi