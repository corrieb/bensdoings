#!/bin/bash

# Builds against vic-machine-base:latest

REPO_NAME="bensdoings"
MAP_VERSION="1.1"
VERSION="1.1.0"

actions=( "create" "debug" "delete" "inspect" "ls" "rollback" "upgrade" "thumbprint" "firewall-allow" "firewall-deny" "dumpargs" "direct" )

cd ../../vic-machine-base/$VERSION
docker build -t vic-machine-base .
cd ../../actions/$MAP_VERSION
cp ../Dockerfile* .

for i in "${actions[@]}"
do
   docker build -f Dockerfile.$i -t $REPO_NAME/vic-machine-$i:$VERSION .
done

rm Dockerfile*

