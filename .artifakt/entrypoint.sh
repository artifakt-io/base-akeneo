#!/bin/bash

set -e

echo ">>>>>>>>>>>>>> START CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "

# set runtime env. vars on the fly
export APP_ENV=prod
export APP_DATABASE_NAME=${ARTIFAKT_MYSQL_DATABASE_NAME:-changeme}
export APP_DATABASE_USER=${ARTIFAKT_MYSQL_USER:-changeme}
export APP_DATABASE_PASSWORD=${ARTIFAKT_MYSQL_PASSWORD:-changeme}
export APP_DATABASE_HOST=${ARTIFAKT_MYSQL_HOST:-mysql}
export APP_DATABASE_PORT=${ARTIFAKT_MYSQL_PORT:-3306}
export APP_INDEX_HOSTS='elasticsearch:9200'

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"

su www-data -s /bin/sh -c 'composer install && composer dump-autoload'

wait-for-it.sh $APP_DATABASE_HOST:3306 --timeout=90 -- su www-data -s /bin/sh -c 'sleep 10 && cd /var/www/html/pim-community-standard && APP_ENV=dev php bin/console pim:installer:db --catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/minimal || :'

su www-data -s /bin/sh -c 'php ./bin/console pim:user:create kbeck secretp@ssw0rd kbeck@example.com Kent Beck en_US --admin -n'

# CLEAN
# mkdir -p /data/var/log /data/var/uploads /data/var/cache && \
#   ln -s /data/var /var/www/html/var && \
#   chown -R www-data:www-data /var/www/html/ /data/var

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
