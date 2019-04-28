#!/bin/bash
#
# /usr/local/bin/start.sh
# Start Logstash and services
#
# spujadas 2015-10-09; added initial pidfile removal and graceful termination

# WARNING - This script assumes that the ELK services are not running, and is
#   only expected to be run once, when the container is started.
#   Do not attempt to run this script if the ELK services are running (or be
#   prepared to reap zombie processes).

## handle termination gracefully

_term() {
  echo "Terminating logstash"
  service logstash stop
  exit 0
}

trap _term SIGTERM

## remove pidfiles in case previous graceful termination failed
# NOTE - This is the reason for the WARNING at the top - it's a bit hackish,
#   but if it's good enough for Fedora (https://goo.gl/88eyXJ), it's good
#   enough for me :)

rm -f /var/run/logstash.pid

## initialise list of log files to stream in console (initially empty)
OUTPUT_LOGFILES=""

# modify configuration
/usr/local/bin/replace_ips.sh

## override default time zone (Etc/UTC) if TZ variable is set
if [ ! -z "$TZ" ]; then
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

## start services as needed

### cron
service cron start

### Logstash

if [ -z "$LOGSTASH_START" ]; then
  LOGSTASH_START=1
fi
if [ "$LOGSTASH_START" -ne "1" ]; then
  echo "LOGSTASH_START is set to something different from 1, not starting..."
else
  # override LS_HEAP_SIZE variable if set
  if [ ! -z "$LS_HEAP_SIZE" ]; then
    awk -v LINE="-Xmx$LS_HEAP_SIZE" '{ sub(/^.Xmx.*/, LINE); print; }' /opt/logstash/config/jvm.options \
        > /opt/logstash/config/jvm.options.new && mv /opt/logstash/config/jvm.options.new /opt/logstash/config/jvm.options
    awk -v LINE="-Xms$LS_HEAP_SIZE" '{ sub(/^.Xms.*/, LINE); print; }' /opt/logstash/config/jvm.options \
        > /opt/logstash/config/jvm.options.new && mv /opt/logstash/config/jvm.options.new /opt/logstash/config/jvm.options
  fi

  # override LS_OPTS variable if set
  if [ ! -z "$LS_OPTS" ]; then
    awk -v LINE="LS_OPTS=\"$LS_OPTS\"" '{ sub(/^LS_OPTS=.*/, LINE); print; }' /etc/init.d/logstash \
        > /etc/init.d/logstash.new && mv /etc/init.d/logstash.new /etc/init.d/logstash && chmod +x /etc/init.d/logstash
  fi

  service logstash start
  OUTPUT_LOGFILES+="/var/log/logstash/logstash-plain.log "
fi

# Exit if nothing has been started
if [ "$LOGSTASH_START" -ne "1" ]; then
  >&2 echo "No services started. Exiting."
  exit 1
fi

touch $OUTPUT_LOGFILES
tail -f $OUTPUT_LOGFILES &
wait
