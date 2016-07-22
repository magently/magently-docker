#!/bin/bash
set -e

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

# Add www-data to hostuser's group
usermod -a -G "$HOST_GROUP" www-data

# Handle user
if [ $UID_EXISTS == "0" ]; then
  useradd -m -g "$HOST_GROUP" -u $HOST_UID hostuser
  HOST_USER="hostuser"
else
  HOST_USER="$(getent passwd $HOST_UID | cut -d: -f1)"
fi

export HOST_USER
export HOST_GROUP
export APP_PATH="/app$(echo "$SYNC_DIRS" | cut -d: -f1)"
export DOCROOT_PATH="$(echo "$SYNC_DIRS" | cut -d: -f2)"
export SAVE_PATH=/tmp/html.save

chown -R "$HOST_USER":"$HOST_GROUP" "$DOCROOT_PATH"

# Create htdocs.save
[ -e "$SAVE_PATH" ] || gosu "$HOST_USER" mkdir "$SAVE_PATH"

chown -R "$HOST_USER":"$HOST_GROUP" "$DOCROOT_PATH"

gosu "$HOST_USER" /scripts/revert-app-symlinks.sh
gosu "$HOST_USER" /scripts/create-app-symlinks.sh

case "$@" in
  "bash")                 exec "$@" ;;
  "/bin/bash")            exec "$@" ;;
  "apache2-foreground")   exec "$@" ;;
  "supervisord")          exec "$@" ;;
  "/usr/bin/supervisord") exec "$@" ;;
  "")                               ;;
  *)                      exec gosu "$HOST_USER" "$@" ;;
esac
