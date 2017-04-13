#!/bin/bash

unique=e09f3rp9ac09ajjrw3r09aemriwelkm
map=$(cat $2 | jq -c '.' | sed "s/\"\././g; s/\"\,/,/g; s/\"\}/}/g")
query="$map | del(.[] | nulls)"

# Remove ":" and replace with unique token (don't replace all colons); replace token with =; separate with spaces; remove leading and trailing brackets; remove remaining quotes
# Note that --option=true gets corrected to --option, so in the case that you want --no-tls, you specify "no-tls": "true" in the JSON. If you don't want that option, remove it from the JSON
cat $1 | jq -c "$query" \
| sed "s/\":\"/\"$unique\"/g; s/$unique/=/g; s/,/ /g; s/{//g; s/}//g; s/\"//g; s/=true//g"
