#!/bin/bash

usage()
{
   echo "Usage: test-client.sh <pi iterations>"
   exit 1
}

if [ $# -lt 1 ]; then usage; fi

. ./env.sh

SPARK_HOME="/usr/local/spark-2.2.0-bin-hadoop2.7"
PI_ITERATIONS=$1

echo "Running SparkPi with iterations = $PI_ITERATIONS"
docker run --rm --net $SPARK_NET p7hb/docker-spark:2.2.0 $SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi --master spark://$MASTER_CTR:$MASTER_PORT $SPARK_HOME/examples/jars/spark-examples_2.11-2.2.0.jar $PI_ITERATIONS
