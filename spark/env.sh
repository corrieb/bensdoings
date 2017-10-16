#!/bin/bash

MASTER_WEBUI_PORT=8080
SLAVE_WEBUI_PORT=8081
MASTER_PORT=7077
MASTER_CTR="spark-master"
SLAVE_CTR="spark-slave"
SPARK_NET="spark-net"

SLAVE_CPUS=2
MASTER_CPUS=2

SLAVE_COUNT=$1
SLAVE_MEM=4g
MASTER_MEM=4g

COMMON_JVM_OPTS="-Djava.net.preferIPv4Stack=true"

# No need to specify heap sizes - will auto-adjust to container size
SLAVE_JVM_OPTS="$COMMON_JVM_OPTS"
MASTER_JVM_OPTS="$COMMON_JVM_OPTS"

