#!/bin/bash
set -e

CONFIG_DIR="/config"
CONFIG_FILE="$CONFIG_DIR/config.json"
CERT_PATH="/certs"
MASTER_NAME="manager1"
LOG_DIR="$CONFIG_DIR/logs"
SSH_CERT_PATH="$CERT_PATH/.ssh"

# Clear and create log dir
[ -d $LOG_DIR ] && rm -fr $LOG_DIR
mkdir -p $LOG_DIR

validate_config()
{
   set +e
   if [ -z ${DOCKER_HOST+x} ]; then
      echo "Environment variable DOCKER_HOST needs to be set to a valid VCH"
      exit 1
   fi 

   if [ ! -f "$CERT_PATH/key.pem" ]; then
      echo "Certificate path needs to be mounted as a volume at $CERT_PATH"
      exit 1
   fi

   if [ ! -f $CONFIG_FILE ]; then
      echo "JSON config file must be at path /config/config.json by mounting /config as a volume"
      exit 1
   fi
   
   docker info > "$LOG_DIR/docker-info-test" 2>&1
   if [ ! $? -eq 0 ]; then
      echo "Could not connect to DOCKER_HOST, please check that it is correctly configured"
      cat "$LOG_DIR/docker-info-test"
      exit 1
   fi
}

export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=$CERT_PATH

validate_config

MANAGER_COUNT="$(jq -r ".swarm.manager_count" $CONFIG_FILE)"
WORKER_COUNT="$(jq -r ".swarm.worker_count" $CONFIG_FILE)"

# Params
#   node name
#   volume name
delete_node()
{
   set +e
   echo "Deleting node $1..."
   docker stop $1 >> "$LOG_DIR/node-stop.output"
   docker rm $1 >> "$LOG_DIR/node-rm.output"
   docker volume rm $2 >> "$LOG_DIR/volume-rm.output"
   echo "Done deleting $1"
   touch "/tmp/$1.done"
}

delete_nodes()
{
   for ((i=1; i<=$MANAGER_COUNT; i++))
   do
      delete_node "manager"$i"" "m"$i"-vol" &
   done

   for ((i=1; i<=$WORKER_COUNT; i++))
   do
      delete_node "worker"$i"" "w"$i"-vol" &
   done
}

wait_for_completion()
{
   total_nodes=$(($MANAGER_COUNT+$WORKER_COUNT))
   while [ $(if [ -f "/tmp/$MASTER_NAME.done" ];then ls /tmp/*.done; fi | wc -l) -lt $total_nodes ]; do
      sleep 2
   done
}

delete_nodes

wait_for_completion
