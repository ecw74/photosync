#!/usr/bin/env bash

# Standardwerte, falls keine Umgebungsvariablen gesetzt sind
LOCAL_USER_ID=${USER_ID:-1000}
LOCAL_GROUP_ID=${GROUP_ID:-1000}

# Erstellen/Anpassen von appgroup und appuser
if ! getent group appgroup >/dev/null; then
  addgroup -g ${LOCAL_GROUP_ID} appgroup
fi

if getent passwd appuser >/dev/null; then
  deluser appuser
fi

adduser -D -u ${LOCAL_USER_ID} -G appgroup appuser

# If the CRON variable is empty, phockup gets executed once as command line tool
if [ -z "$CRON_1" ] && [ -z "$CRON_2" ]; then
  if [ -n "$SOURCE_PATH_1" ] && [ -n "$DESTINATION_PATH" ]; then
    exec su-exec appuser /opt/app/move_media.sh "$SOURCE_PATH_1" "$DESTINATION_PATH"
  else
    echo "SOURCE_PATH_1 not defined."
  fi

  if [ -n "$SOURCE_PATH_2" ] && [ -n "$DESTINATION_PATH" ]; then
    exec su-exec appuser /opt/app/move_media.sh "$SOURCE_PATH_2" "$DESTINATION_PATH"
  else
    echo "SOURCE_PATH_2 not defined."
  fi
else
  rm -rf /tmp/sync.lockfile
  rm -rf /etc/crontabs/appuser
  touch /etc/crontabs/appuser

  if [ -n "$SOURCE_PATH_1" ] && [ -n "$DESTINATION_PATH" ]; then
    echo "$CRON_1 flock -w 300 /tmp/sync.lockfile /opt/app/move_media.sh \"$SOURCE_PATH_1\" \"$DESTINATION_PATH\"" >> /etc/crontabs/appuser
  fi

  if [ -n "$SOURCE_PATH_2" ] && [ -n "$DESTINATION_PATH" ]; then
    echo "$CRON_2 flock -w 300 /tmp/sync.lockfile /opt/app/move_media.sh \"$SOURCE_PATH_2\" \"$DESTINATION_PATH\"" >> /etc/crontabs/appuser
  fi

  chown appuser:appgroup /etc/crontabs/appuser
  chmod 600 /etc/crontabs/appuser
  echo "Cron job has been set up with command: $CRON_COMMAND"

  crond -f -d 8
fi