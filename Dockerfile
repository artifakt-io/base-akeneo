FROM registry.artifakt.io/akeneo:5-apache

ENV APP_DEBUG=0
ENV APP_ENV=prod

WORKDIR /var/www/html/pim-community-standard

COPY --chown=www-data:www-data . /var/www/html/pim-community-standard

RUN [ -f composer.lock ] && /usr/local/bin/composer install --no-cache --optimize-autoloader --no-interaction --no-ansi --no-dev || true

# copy the artifakt folder on root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN  if [ -d .artifakt ]; then cp -rp /var/www/html/pim-community-standard/.artifakt /.artifakt/; fi

# PERSISTENT DATA FOLDERS
RUN rm -rf /var/www/html/pim-community-standard/var && \
  mkdir -p /data/var && \
  ln -s /data/var /var/www/html/pim-community-standard/var && \
  chown -R www-data:www-data /data/var /var/www/html/pim-community-standard/var

# FAILSAFE LOG FOLDER
RUN mkdir -p /var/log/artifakt && chown www-data:www-data /var/log/artifakt

# run custom scripts build.sh
# hadolint ignore=SC1091
RUN --mount=source=artifakt-custom-build-args,target=/tmp/build-args \
  if [ -f /tmp/build-args ]; then source /tmp/build-args; fi && \
  if [ -f /.artifakt/build.sh ]; then /.artifakt/build.sh; fi
