#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"

su www-data -s /bin/sh -c 'composer install && composer dump-autoload'

chmod 755 /var/www/html/pim-community-standard/bin/console

#CLEAN
#chown -R www-data:www-data /var/www/html/pim-community-standard/vendor

echo ">>>>>>>>>>>>>> END CUSTOM BUILD SCRIPT <<<<<<<<<<<<<<<<< "
