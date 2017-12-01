#!/bin/bash
# author: paladintyrion

#### start

kafka_input_file="/etc/logstash/conf.d/00-kafka-input.conf"
# echo "需要替换的kafka_input_file为:" $kafka_input_file
es_out_file="/etc/logstash/conf.d/30-output.conf"
# echo "需要替换的es_out_file为:" $es_out_file
host_name=`hostname`

if [ ! -z "$ES_IPS" ]; then
  es_ips="$ES_IPS"
fi

if [ ! -z "$KAFKA_IPS" ]; then
  kafka_ips="$KAFKA_IPS"
fi

if [ ! -z "$GROUP_ID" ]; then
  group_id="$GROUP_ID"
fi

##### replace starts
oldIFS="$IFS"
IFS=","

# deal with es_ip
es_arr=()
for es_ip in $es_ips;
do
  es_arr=("${es_arr[@]}" "\"${es_ip}:9200\"")
done
es_ips_res="[${es_arr[*]// /,}]"

# deal with kafka_ip
kafka_arr=()
for kafka_ip in $kafka_ips;
do
  kafka_arr=("${kafka_arr[@]}" "${kafka_ip}:9092")
done
kafka_ips_res="\"${kafka_arr[*]// /,}\""

IFS="$oldIFS"
##### replace ends


##### modify the all configure
if [ ${#kafka_arr[@]} -gt 0 ]; then
  # replace logstash kafka input
  sed -i -e "s/bootstrap_servers =>.*$/bootstrap_servers => $kafka_ips_res/g" $kafka_input_file
fi

if [ ${#es_arr[@]} -gt 0 ]; then
  # replace logstash elasticsearch output
  sed -i -e "s/hosts =>.*$/hosts => $es_ips_res/g" $es_out_file
fi

# control other param of logstash configure
# kafka-input
sed -i -e "s/client_id =>.*$/client_id => \"${group_id}-${host_name}\"/g" $kafka_input_file
sed -i -e "s/group_id =>.*$/group_id => \"$group_id\"/g" $kafka_input_file
