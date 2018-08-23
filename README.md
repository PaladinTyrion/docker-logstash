docker run -d -it --privileged -p 5044:5044 -p 9600:9600 --name logstash \
  -e DATALOGGING_KAFKA_IPS=10.10.10.1,10.10.10.2,10.10.10.3 \
  -e SERVLOGGING_KAFKA_IPS=10.10.10.1,10.10.10.2,10.10.10.3 \
  -e LIVEDATALOG_KAFKA_IPS=10.10.10.1,10.10.10.2,10.10.10.3 \
  -e LIVESERVLOG_KAFKA_IPS=10.10.10.1,10.10.10.2,10.10.10.3 \
  -e DATALOGGING_GROUP_ID=datalogging \
  -e SERVLOGGING_GROUP_ID=servlogging \
  -e LIVEDATALOG_GROUP_ID=livedatalog \
  -e LIVESERVLOG_GROUP_ID=liveservlog \
  -e ES_IPS=10.10.10.11,10.10.10.12,10.10.10.13,10.10.10.14,10.10.10.15 \
  -e AUTH_USER=paladintyrion \
  -e AUTH_PASSWD=paladintyrion \
  -v /data0/logstash/log:/var/log/logstash \
  -v /data0/logstash/data:/var/lib/logstash \
  -v /data0/logstash/tmp:/tmp/logstash \
  paladintyrion/logstash
