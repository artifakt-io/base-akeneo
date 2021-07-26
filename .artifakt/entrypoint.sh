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

wait-for $APP_DATABASE_HOST:$ARTIFAKT_MYSQL_PORT --timeout=90 -- su www-data -s /bin/bash -c '
  cd /var/www/html/pim-community-standard
  ./bin/console pim:system:information 2>/dev/null;
  if [ $? -ne 0 ]; then
  	echo FIRST DEPLOYMENT, will run default installer
    APP_ENV=dev php bin/console pim:installer:db --withoutIndexes=true --catalog vendor/akeneo/pim-community-dev/src/Akeneo/Platform/Bundle/InstallerBundle/Resources/fixtures/minimal
    php ./bin/console pim:user:create admin password123 user@example.com Admin User en_US --admin -n
  else
  	echo FOUND INSTALLED SYSTEM, will not run installer
  fi
'

echo ">>>>>>>>>>>>>> END CUSTOM ENTRYPOINT SCRIPT <<<<<<<<<<<<<<<<< "
