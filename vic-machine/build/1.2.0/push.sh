#!/bin/bash
set -e

# push to dockerhub
REPO_NAME="bensdoings"

# push to local registry
#   note you'll need to create the project "vic-machine", add yourself to the project and run docker login with your credentials before pushing
# REPO_NAME="10.118.69.29/vic-machine"

VERSION="1.2.0"

actions=( "create" "debug" "delete" "inspect" "ls" "rollback" "upgrade" "thumbprint" "firewall-allow" "firewall-deny" "dumpargs" "direct" )

for i in "${actions[@]}"
do
#   docker tag $REPO_NAME/vic-machine-$i:$VERSION $REPO_NAME/vic-machine-$i:latest
   docker push $REPO_NAME/vic-machine-$i:$VERSION
#   docker push $REPO_NAME/vic-machine-$i:latest
done

