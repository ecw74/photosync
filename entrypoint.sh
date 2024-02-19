#!/usr/bin/env bash

# If the CRON variable is empty, phockup gets executed once as command line tool
if [ -z "$CRON" ]; then
  echo 'Hello World'
# When CRON is not empty, phockup will run in a cron job until the container is stopped.
else
  if [ -f /tmp/photosync.lockfile ]; then
    rm /tmp/photosync.lockfile
  fi

#  CRON_COMMAND="$CRON flock -n /tmp/photosync.lockfile phockup /mnt/input /mnt/output $OPTIONS"
  CRON_COMMAND="$CRON flock -n /tmp/photosync.lockfile echo 'Hello World'"

  echo "$CRON_COMMAND" >> /etc/crontabs/root
  echo "Cron job has been set up with command: $CRON_COMMAND"

  crond -f -d 8
fi