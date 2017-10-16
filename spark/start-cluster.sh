#!/bin/bash

MASTER_WEBUI_PORT=8080
SLAVE_WEBUI_PORT=8081
MASTER_PORT=7077
MASTER_CTR="spark-master"
SLAVE_CTR="spark-slave"
SPARK_NET="spark-net"

SLAVE_CPUS=2
MASTER_CPUS=2

SLAVE_COUNT=20
SLAVE_MEM=4g
MASTER_MEM=4g

COMMON_JVM_OPTS="-Djava.net.preferIPv4Stack=true"

# No need to specify heap sizes - will auto-adjust to container size
SLAVE_JVM_OPTS="$COMMON_JVM_OPTS"
MASTER_JVM_OPTS="$COMMON_JVM_OPTS"

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
