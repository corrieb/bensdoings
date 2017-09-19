#!/bin/bash
set -e

# Params
#   - Config file
#   - Map file

version="1.2"
unique=e09f3rp9ac09ajjrw3r09aemriwelkm

if [ $# -le 1 ]; then 
   echo "Usage: parse.sh <config.json> <action-map-file>"
   exit 1
fi

kv_map=$(cat $2 | jq -c '.key_value' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
kv_query="$kv_map | to_entries[] | select (.value | length > 0) | .key,.value"

#kv_map_quote=$(cat $2 | jq -c '.key_value_quote' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
#kv_query_quote="$kv_map_quote | to_entries[] | select (.value | length > 0) | .key,.value"

bool_map=$(cat $2 | jq -c '.bool' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
bool_query="$bool_map | to_entries[] | select (.value==true) | .key"

array_map=$(cat $2 | jq -c '.array' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
array_query="$array_map | to_entries[] | select (.value | length > 0) | {key, value: .value[]} | .key,.value" 

container_net_map=$(cat $2 | jq -c '.container_network' | sed "s/\"(/(/g; s/\"\,/,/g; s/\"\}/}/g; s/{\"query\":\"//; s/| ,\"/| {\"/; s/':'/\":\"/g")
container_net_query="$container_net_map | to_entries[] | select (.value | length > 0) | .key,.value"

kv_map_output=$(cat $1 | jq -c "$kv_query")
#kv_map_quote_output=$(cat $1 | jq -c "$kv_query_quote")

if [ "$bool_map" != "null" ]; then
   bool_map_output=$(cat $1 | jq -c "$bool_query")
fi
if [ "$array_map" != "null" ]; then
   array_map_output=$(cat $1 | jq -c "$array_query")
fi
if [ "$container_net_map" != "null" ]; then
   container_net_map_output=$(cat $1 | jq -c "$container_net_query")
fi

combine_output=$kv_map_output" "$array_map_output" "$container_net_map_output

# Remove the quotes from just the keys, not the values - only works if bool args are not mixed in
remove_k_quotes=$(echo $combine_output | sed "s/\"--/--/g; s/\" \"/ \"/g; s/\"/\'/g")
# Remove quotes from keys and values
remove_all_quotes=$(echo $bool_map_output | sed "s/\"//g")

echo $remove_all_quotes" "$remove_k_quotes
