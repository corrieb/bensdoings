#!/bin/bash

REPO_NAME="bensdoings"
VERSION="0.9.0"

actions=( "create" "debug" "delete" "inspect" "ls" "upgrade" "thumbprint" "dumpargs" "direct" )

for i in "${actions[@]}"
do
   docker push $REPO_NAME/vic-machine-$i:$VERSION
done

