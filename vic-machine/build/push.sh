#!/bin/bash

REPO_NAME="bensdoings"
VERSION="1.1.1"

actions=( "create" "debug" "delete" "inspect" "ls" "rollback" "upgrade" "thumbprint" "firewall-allow" "firewall-deny" "dumpargs" "direct" )

for i in "${actions[@]}"
do
   docker tag $REPO_NAME/vic-machine-$i:$VERSION $REPO_NAME/vic-machine-$i:latest
   docker push $REPO_NAME/vic-machine-$i:$VERSION
   docker push $REPO_NAME/vic-machine-$i:latest
done

