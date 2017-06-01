#!/bin/bash

# Builds against vic-machine-base:latest

REPO_NAME="bensdoings"
MAP_VERSION="1.1"  # Note that there are no args in 0.9 that are not in 1.1
VERSION="0.9.0"

actions=( "create" "debug" "delete" "inspect" "ls" "upgrade" "thumbprint" "dumpargs" "direct" )

cd ../../vic-machine-base/$VERSION
docker build -t vic-machine-base .
cd ../../actions/$MAP_VERSION
cp ../Dockerfile* .

for i in "${actions[@]}"
do
   docker build -f Dockerfile.$i -t $REPO_NAME/vic-machine-$i:$VERSION .
done

rm Dockerfile*

