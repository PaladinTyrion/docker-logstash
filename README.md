docker run -d -it --privileged -p 5044:5044 -p 9600:9600 --name logstash \
  -e KAFKA_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e ES_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e GROUP_ID=logging \
  -v /data0/logstash/log:/var/log/logstash \
  -v /data0/logstash/data:/var/lib/logstash \
  -v /data0/logstash/tmp:/tmp/logstash \
  paladintyrion/logstash
