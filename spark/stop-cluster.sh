#!/bin/bash

set -e

. ./env.sh

CONTAINER_IDS=$(docker ps -f "name=$MASTER_CTR" -f "name=$SLAVE_CTR" -q)

echo "Stopping containers"
docker stop $CONTAINER_IDS > /dev/null
echo "Removing containers"
docker rm $CONTAINER_IDS > /dev/null
echo "Removing network $SPARK_NET"
docker network rm $SPARK_NET > /dev/null

