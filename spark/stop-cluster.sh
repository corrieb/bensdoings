#!/bin/bash

. ./env.sh

CONTAINER_IDS=$(docker ps -f "name=$MASTER_CTR" -f "name=$SLAVE_CTR" -q)

docker stop $CONTAINER_IDS
docker rm $CONTAINER_IDS

