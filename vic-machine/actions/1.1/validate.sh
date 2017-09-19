#!/bin/bash

# Params
#   - Config file
#   - Map file

version="1.1"

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

# Support previous and current versions
config_version=$(cat $1 | jq -r '.version')
if (( $(echo "$version < $config_version" |bc -l) )); then
   echo "Config file version: $config_version is not compatible with parser version: $version"
   exit 1
fi

