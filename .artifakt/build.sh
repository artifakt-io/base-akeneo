#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"

su www-data -s /bin/sh -c 'composer install --no-cache --optimize-autoloader --no-interaction --no-ansi && composer dump-autoload'
su www-data -s /bin/sh -c 'cp /tmp/build-args /var/www/html/.build-args'

chmod 755 /var/www/html/pim-community-standard/bin/console
chmod 755 /var/www/html/.build-args

echo ">>>>>>>>>>>>>> END CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "
