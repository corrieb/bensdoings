#!/bin/bash

REPO_NAME="bensdoings"
VERSION="1.1.0"

actions=( "create" "debug" "delete" "inspect" "ls" "rollback" "upgrade" "thumbprint" "firewall-allow" "firewall-deny" "dumpargs" "direct" )

for i in "${actions[@]}"
do
   docker push $REPO_NAME/vic-machine-$i:$VERSION
done

