#!/bin/bash
# author: paladintyrion

#### start

kafka_input_file="/etc/logstash/conf.d/00-kafka-input.conf"
# echo "需要替换的kafka_input_file为:" $kafka_input_file
es_out_file="/etc/logstash/conf.d/30-output.conf"
# echo "需要替换的es_out_file为:" $es_out_file
jaas_config_file="/etc/logstash/kafka-client-jaas.conf"
# echo "需要替换的jaas_config_file为:" $jaas_config_file
host_name=`hostname`

if [ ! -z "$ES_IPS" ]; then
  es_ips="$ES_IPS"
fi

if [ ! -z "$DATALOGGING_KAFKA_IPS" ]; then
  datalogging_kafka_ips="$DATALOGGING_KAFKA_IPS"
fi

if [ ! -z "$SERVLOGGING_KAFKA_IPS" ]; then
  servlogging_kafka_ips="$SERVLOGGING_KAFKA_IPS"
fi

if [ ! -z "$LIVEDATALOG_KAFKA_IPS" ]; then
  livedatalog_kafka_ips="$LIVEDATALOG_KAFKA_IPS"
fi

if [ ! -z "$LIVESERVLOG_KAFKA_IPS" ]; then
  liveservlog_kafka_ips="$LIVESERVLOG_KAFKA_IPS"
fi

if [ ! -z "$DATALOGGING_GROUP_ID" ]; then
  datalogging_group_id="$DATALOGGING_GROUP_ID"
fi

if [ ! -z "$SERVLOGGING_GROUP_ID" ]; then
  servlogging_group_id="$SERVLOGGING_GROUP_ID"
fi

if [ ! -z "$LIVEDATALOG_GROUP_ID" ]; then
  livedatalog_group_id="$LIVEDATALOG_GROUP_ID"
fi

if [ ! -z "$LIVESERVLOG_GROUP_ID" ]; then
  liveservlog_group_id="$LIVESERVLOG_GROUP_ID"
fi

if [ ! -z "$AUTH_USER" ]; then
  auth_user="$AUTH_USER"
fi

if [ ! -z "$AUTH_PASSWD" ]; then
  auth_passwd="$AUTH_PASSWD"
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

# deal with datalogging_kafka_ip
datalogging_kafka_arr=()
for datalogging_kafka_ip in $datalogging_kafka_ips;
do
  datalogging_kafka_arr=("${datalogging_kafka_arr[@]}" "${datalogging_kafka_ip}:9110")
done
datalogging_kafka_ips_res="\"${datalogging_kafka_arr[*]// /,}\""

# deal with servlogging_kafka_ip
servlogging_kafka_arr=()
for servlogging_kafka_ip in $servlogging_kafka_ips;
do
  servlogging_kafka_arr=("${servlogging_kafka_arr[@]}" "${servlogging_kafka_ip}:9110")
done
servlogging_kafka_ips_res="\"${servlogging_kafka_arr[*]// /,}\""

# deal with livedatalog_kafka_ip
livedatalog_kafka_arr=()
for livedatalog_kafka_ip in $livedatalog_kafka_ips;
do
  livedatalog_kafka_arr=("${livedatalog_kafka_arr[@]}" "${livedatalog_kafka_ip}:9110")
done
livedatalog_kafka_ips_res="\"${livedatalog_kafka_arr[*]// /,}\""

# deal with liveservlog_kafka_ip
liveservlog_kafka_arr=()
for liveservlog_kafka_ip in $liveservlog_kafka_ips;
do
  liveservlog_kafka_arr=("${liveservlog_kafka_arr[@]}" "${liveservlog_kafka_ip}:9110")
done
liveservlog_kafka_ips_res="\"${liveservlog_kafka_arr[*]// /,}\""


IFS="$oldIFS"
##### replace ends


##### modify the all configure
if [ ${#datalogging_kafka_arr[@]} -gt 0 ]; then
  # replace logstash kafka input
  sed -i -e "1,/bootstrap_servers => \"0.0.0.0:9092\"/s/bootstrap_servers => \"0.0.0.0:9092\"/bootstrap_servers => $datalogging_kafka_ips_res/" $kafka_input_file
fi
if [ ${#servlogging_kafka_arr[@]} -gt 0 ]; then
  # replace logstash kafka input
  sed -i -e "1,/bootstrap_servers => \"0.0.0.0:9092\"/s/bootstrap_servers => \"0.0.0.0:9092\"/bootstrap_servers => $servlogging_kafka_ips_res/" $kafka_input_file
fi
if [ ${#livedatalog_kafka_arr[@]} -gt 0 ]; then
  # replace logstash kafka input
  sed -i -e "1,/bootstrap_servers => \"0.0.0.0:9092\"/s/bootstrap_servers => \"0.0.0.0:9092\"/bootstrap_servers => $livedatalog_kafka_ips_res/" $kafka_input_file
fi
if [ ${#liveservlog_kafka_arr[@]} -gt 0 ]; then
  # replace logstash kafka input
  sed -i -e "1,/bootstrap_servers => \"0.0.0.0:9092\"/s/bootstrap_servers => \"0.0.0.0:9092\"/bootstrap_servers => $liveservlog_kafka_ips_res/" $kafka_input_file
fi


if [ ${#es_arr[@]} -gt 0 ]; then
  # replace logstash elasticsearch output
  sed -i -e "s/hosts =>.*$/hosts => $es_ips_res/g" $es_out_file
fi

# control other param of logstash configure
# datalogging:kafka-input
if [ ! -z "$datalogging_group_id" ]; then
  sed -i -e "1,/client_id => \"logstash\"/s/client_id => \"logstash\"/client_id => \"${datalogging_group_id}-${host_name}\"/" $kafka_input_file
  sed -i -e "1,/group_id => \"logstash\"/s/group_id => \"logstash\"/group_id => \"$datalogging_group_id\"/" $kafka_input_file
fi

# servlogging:kafka-input
if [ ! -z "$servlogging_group_id" ]; then
  sed -i -e "1,/client_id => \"logstash\"/s/client_id => \"logstash\"/client_id => \"${servlogging_group_id}-${host_name}\"/" $kafka_input_file
  sed -i -e "1,/group_id => \"logstash\"/s/group_id => \"logstash\"/group_id => \"$servlogging_group_id\"/" $kafka_input_file
fi

# livedatalog:kafka-input
if [ ! -z "$livedatalog_group_id" ]; then
  sed -i -e "1,/client_id => \"logstash\"/s/client_id => \"logstash\"/client_id => \"${livedatalog_group_id}-${host_name}\"/" $kafka_input_file
  sed -i -e "1,/group_id => \"logstash\"/s/group_id => \"logstash\"/group_id => \"$livedatalog_group_id\"/" $kafka_input_file
fi

# liveservlog:kafka-input
if [ ! -z "$liveservlog_group_id" ]; then
  sed -i -e "1,/client_id => \"logstash\"/s/client_id => \"logstash\"/client_id => \"${liveservlog_group_id}-${host_name}\"/" $kafka_input_file
  sed -i -e "1,/group_id => \"logstash\"/s/group_id => \"logstash\"/group_id => \"$liveservlog_group_id\"/" $kafka_input_file
fi

# control kafka jaas
if [ ! -z "$auth_user" ]; then
  sed -i -e "s/\"username\"/\"$auth_user\"/" $jaas_config_file
fi

if [ ! -z "$auth_passwd" ]; then
  sed -i -e "s/\"password\"/\"$auth_passwd\"/" $jaas_config_file
fi
