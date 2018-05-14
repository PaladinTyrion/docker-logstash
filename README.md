docker run -d -it --privileged -p 5044:5044 -p 9600:9600 --name logstash \
  -e DATALOGGING_KAFKA_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e SERVLOGGING_KAFKA_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e LIVEDATALOG_KAFKA_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e LIVESERVLOG_KAFKA_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e DATALOGGING_GROUP_ID=datalogging \
  -e SERVLOGGING_GROUP_ID=servlogging \
  -e LIVEDATALOG_GROUP_ID=livedatalog \
  -e LIVESERVLOG_GROUP_ID=liveservlog \
  -e ES_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e AUTH_USER=paladintyrion \
  -e AUTH_PASSWD=paladintyrion \
  -v /data0/logstash/log:/var/log/logstash \
  -v /data0/logstash/data:/var/lib/logstash \
  -v /data0/logstash/tmp:/tmp/logstash \
  paladintyrion/logstash
