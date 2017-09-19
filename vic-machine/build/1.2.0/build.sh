#!/bin/bash
set -e 

BUILD_FROM_OVA=false

# build for pushing to dockerhub
REPO_NAME="bensdoings"

# build for pushing to local registry
# REPO_NAME="10.118.69.29/vic-machine"

MAP_VERSION="1.2"
VERSION="1.2.0"

actions=( "create" "debug" "delete" "inspect" "ls" "rollback" "upgrade" "thumbprint" "firewall-allow" "firewall-deny" "dumpargs" "direct" )

if [ "$BUILD_FROM_OVA" = true ]; then
  cd ../../vic-machine-base/OVA
else
  cd ../../vic-machine-base/$VERSION
fi

docker build -t vic-machine-base .

cd ../../actions/$MAP_VERSION
cp ../Dockerfile* .

for i in "${actions[@]}"
do
   docker build -f Dockerfile.$i -t $REPO_NAME/vic-machine-$i:$VERSION .
done

rm Dockerfile*

