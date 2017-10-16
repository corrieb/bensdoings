#!/bin/bash

usage()
{
   echo "Usage: start-cluster.sh <num-slaves>"
   exit 1
}

if [ $# -lt 1 ]; then usage; fi

. ./env.sh

docker network create spark-net

docker run -d \
  --name $MASTER_CTR \
  -e _JAVA_OPTIONS="$MASTER_JVM_OPTS" \
  -e SPARK_MASTER_HOST=$MASTER_CTR \
  -e SPARK_MASTER_PORT=$MASTER_PORT \
  -e SPARK_MASTER_WEBUI_PORT=$MASTER_WEBUI_PORT \
  --cpuset-cpus=$MASTER_CPUS \
  -m $MASTER_MEM \
  -p $MASTER_WEBUI_PORT:$MASTER_WEBUI_PORT \
  --net $SPARK_NET \
  bensdoings/spark-master

for ((i=1; i<=$SLAVE_COUNT; i++))
do
  docker run -d \
    --name $SLAVE_CTR$i \
    -e _JAVA_OPTIONS="$SLAVE_JVM_OPTS" \
    -e MASTER_CTR=$MASTER_CTR \
    -e MASTER_PORT=$MASTER_PORT \
    -e SPARK_WORKER_WEBUI_PORT=$SLAVE_WEBUI_PORT \
    --cpuset-cpus=$SLAVE_CPUS \
    -m $SLAVE_MEM \
    -p $SLAVE_WEBUI_PORT \
    --net $SPARK_NET \
    bensdoings/spark-slave &
  sleep 1
done
