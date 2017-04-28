#!/bin/bash
set -e

# Params
#   - Config file
#   - Map file

version="1.1"
unique=e09f3rp9ac09ajjrw3r09aemriwelkm

if [ $# -le 1 ]; then 
   echo "Usage: parse.sh <config.json> <action-map-file>"
   exit 1
fi

if [ ! -f $1 ]; then
   echo "Config file $1 does not exist - use -v <file>:/config"
   exit 1
fi

if [ ! -f $2 ]; then
   echo "Map file $2 does not exist"
   exit 1
fi

config_version=$(cat $1 | jq -r '.version')
if [ $version != $config_version ]; then
   echo "Config file version: $config_version does not match parser version: $version"
   exit 1
fi

kv_map=$(cat $2 | jq -c '.key_value' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
kv_query="$kv_map | to_entries[] | select (.value | length > 0) | .key,.value"

bool_map=$(cat $2 | jq -c '.bool' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
bool_query="$bool_map | to_entries[] | select (.value==true) | .key"

array_map=$(cat $2 | jq -c '.array' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
array_query="$array_map | to_entries[] | select (.value | length > 0) | {key, value: .value[]} | .key,.value" 

container_net_map=$(cat $2 | jq -c '.container_network' | sed "s/\"(/(/g; s/\"\,/,/g; s/\"\}/}/g; s/{\"query\":\"//; s/| ,\"/| {\"/; s/':'/\":\"/g")
container_net_query="$container_net_map | to_entries[] | select (.value | length > 0) | .key,.value"

kv_map_output=$(cat $1 | jq -c "$kv_query")

if [ "$bool_map" != "null" ]; then
   bool_map_output=$(cat $1 | jq -c "$bool_query")
fi
if [ "$array_map" != "null" ]; then
   array_map_output=$(cat $1 | jq -c "$array_query")
fi
if [ "$container_net_map" != "null" ]; then
  container_net_map_output=$(cat $1 | jq -c "$container_net_query")
fi

combine_output=$kv_map_output" "$bool_map_output" "$array_map_output" "$container_net_map_output

remove_quotes=$(echo $combine_output | sed "s/\"//g")

echo $remove_quotes
