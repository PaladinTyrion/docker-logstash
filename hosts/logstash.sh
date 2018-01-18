#!/bin/bash

# create dir
mkdir -p /data0/logstash/data /data0/logstash/log /data0/logstash/tmp
chmod -R +x /data0/logstash

### create groups && users
# create logstash user
id "logstash" >& /dev/null
if [ $? -ne 0 ]
then
    groupadd -r logstash -g 442
    useradd -r -s /usr/sbin/nologin -c "Logstash service user" -u 442 -g logstash logstash
fi

# chown groups && users
chown -R logstash:logstash /data0/logstash
