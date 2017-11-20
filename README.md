docker run -d -p 9600:9600 -p 5044:5044 --privileged -v /data0/logstash/config:/opt/logstash/pipeline --name logstash paladintyrion/logstash
