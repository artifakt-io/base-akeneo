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

ES_PROTOCOL=""
if [[ "$ARTIFAKT_ES_PORT" == "443" ]]; then
  ES_PROTOCOL="https://"
fi
export APP_INDEX_HOSTS=${ES_PROTOCOL:-http://}${ARTIFAKT_ES_HOST:-elasticsearch}:${ARTIFAKT_ES_PORT:-9200}

echo "------------------------------------------------------------"
echo "The following build args are available:"
env
echo "------------------------------------------------------------"

wait-for ${ARTIFAKT_ES_HOST:-elasticsearch}:${ARTIFAKT_ES_PORT:-9200} --timeout=30

wait-for $APP_DATABASE_HOST:3306 --timeout=90 -- su www-data -s /bin/sh -c 'sleep 10 && cd /var/www/html/pim-community-standard && APP_ENV=dev php bin/console pim:installer:db --withoutIndexes=true --catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/minimal || :'

su www-data -s /bin/sh -c 'php ./bin/console pim:user:create admin password123 user@example.com Admin User en_US --admin -n'

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
