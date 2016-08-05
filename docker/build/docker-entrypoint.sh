#!/bin/bash
set -e

umask 002

HOST_UID=$(stat -c "%u" .)
HOST_GID=$(stat -c "%g" .)

UID_EXISTS=$(cat /etc/passwd | grep ":$HOST_UID:" | wc -l)
GID_EXISTS=$(cat /etc/group | grep ":$HOST_GID:" | wc -l)

# Handle user's group
if [ $GID_EXISTS == "0" ]; then
  # Create new group using target GID
  groupadd -g $HOST_GID hostgroup
  HOST_GROUP="hostgroup"
else
  HOST_GROUP="$(getent group $HOST_GID | cut -d: -f1)"
fi

# Handle user
if [ $UID_EXISTS == "0" ]; then
  useradd -m -g "$HOST_GROUP" -u $HOST_UID hostuser
  HOST_USER="hostuser"
else
  HOST_USER="$(getent passwd $HOST_UID | cut -d: -f1)"
fi

# Add www-data to hostuser's group
usermod -a -G "$HOST_GROUP" www-data
usermod -a -G www-data "$HOST_USER"

export HOST_USER
export HOST_GROUP

function sync_dirs
{
  export SYNC_SRC="/app$(echo "$SYNC_DIRS" | cut -d: -f1)"
  export SYNC_DEST="$(echo "$SYNC_DIRS" | cut -d: -f2)"

  # Make sure sync destination exists
  if [ -e "$SYNC_DEST" ]; then
    chown -R "$HOST_USER":"$HOST_GROUP" "$SYNC_DEST"
  else
    gosu "www-data" mkdir -p "${SYNC_DEST%/*}"
    chown "$HOST_USER":"$HOST_GROUP" "${SYNC_DEST%/*}"
  fi

  # Create htdocs.save
  [ -e "$SAVE_PATH" ] || gosu "$HOST_USER" mkdir "$SAVE_PATH"

  gosu "$HOST_USER" /scripts/revert-app-symlinks.sh
  gosu "$HOST_USER" /scripts/create-app-symlinks.sh
}

function install_magento
{
  if [ ! -d "$MAGENTO_PATH" ]; then
    chmod g+ws "${MAGENTO_PATH%/*}"
    
    # Create Magento 2 project
    gosu "$HOST_USER" composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition "$MAGENTO_PATH" "$MAGENTO_VERSION"

    # Require package
    gosu "$HOST_USER" composer config -d "$MAGENTO_PATH" minimum-stability "dev" 2>/dev/null
    gosu "$HOST_USER" composer config -d "$MAGENTO_PATH" repositories.1 "{\"type\": \"path\", \"url\": \"$MODULE_PATH\"}" 2>/dev/null
    gosu "$HOST_USER" composer require -d "$MAGENTO_PATH" "$MODULE_NAME"

    # Install Magento 2
    gosu "$HOST_USER" php "$MAGENTO_PATH/bin/magento" setup:install \
      --base-url=$MAGENTO_URL \
      --backend-frontname=admin \
      --language=$MAGENTO_LANGUAGE \
      --timezone=$MAGENTO_TIMEZONE \
      --currency=$MAGENTO_DEFAULT_CURRENCY \
      --db-host=$MYSQL_HOST \
      --db-name=$MYSQL_DATABASE \
      --db-user=$MYSQL_USER \
      --db-password=$MYSQL_PASSWORD \
      --use-secure=0 \
      --base-url-secure=0 \
      --use-secure-admin=0 \
      --admin-firstname=$MAGENTO_ADMIN_FIRSTNAME \
      --admin-lastname=$MAGENTO_ADMIN_LASTNAME \
      --admin-email=$MAGENTO_ADMIN_EMAIL \
      --admin-user=$MAGENTO_ADMIN_USERNAME \
      --admin-password=$MAGENTO_ADMIN_PASSWORD

  elif [ $UPDATE_MODULE_ON_START -eq 1 ]; then
    gosu "$HOST_USER" composer update -d "$MAGENTO_PATH" "$MODULE_NAME"
  fi
}

function run
{
  if [ -n "$SYNC_DIRS" ]; then
    sync_dirs
  fi

  # Install magento
  install_magento

  # Inject templates
  gosu www-data dockerize \
    -template "$APP_PATH/docker/build/conf/phpunit.unit.xml.tmpl:$MAGENTO_PATH/dev/tests/unit/phpunit.xml" \
    -template "$APP_PATH/docker/build/conf/phpunit.integration.xml.tmpl:$MAGENTO_PATH/dev/tests/integration/phpunit.xml" \
    -template "$APP_PATH/docker/build/conf/install-config-mysql.php.tmpl:$MAGENTO_PATH/dev/tests/integration/etc/install-config-mysql.php"

  dockerize \
    -template "$APP_PATH/docker/build/conf/000-default.conf.tmpl:/etc/apache2/sites-available/000-default.conf"
    
  exec "$@"
}

case "$@" in
  "bash")                 run "$@" ;;
  "/bin/bash")            run "$@" ;;
  "apache2-foreground")   run "$@" ;;
  "supervisord")          run "$@" ;;
  "/usr/bin/supervisord") run "$@" ;;
  "")                               ;;
  *)                      run gosu "$HOST_USER" "$@" ;;
esac
