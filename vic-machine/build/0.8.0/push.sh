#!/bin/bash

REPO_NAME="bensdoings"
VERSION="0.8.0"

actions=( "create" "debug" "delete" "inspect" "ls" "thumbprint" "dumpargs" "direct" )

for i in "${actions[@]}"
do
   docker push $REPO_NAME/vic-machine-$i:$VERSION
done

