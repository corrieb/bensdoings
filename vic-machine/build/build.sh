#!/bin/bash

# Builds against vic-machine-base:latest

REPO_NAME="bensdoings"
MAP_VERSION="1.1.0"
VERSION="1.1.1"

cd ../actions/$MAP_VERSION
cp ../Dockerfile* .
docker build -f Dockerfile.create -t $REPO_NAME/vic-machine-create:$VERSION .
docker build -f Dockerfile.debug -t $REPO_NAME/vic-machine-debug:$VERSION .
docker build -f Dockerfile.delete -t $REPO_NAME/vic-machine-delete:$VERSION .
docker build -f Dockerfile.inspect -t $REPO_NAME/vic-machine-inspect:$VERSION .
docker build -f Dockerfile.ls -t $REPO_NAME/vic-machine-ls:$VERSION .
docker build -f Dockerfile.rollback -t $REPO_NAME/vic-machine-rollback:$VERSION .
docker build -f Dockerfile.upgrade -t $REPO_NAME/vic-machine-upgrade:$VERSION .
docker build -f Dockerfile.thumbprint -t $REPO_NAME/vic-machine-thumbprint:$VERSION .
docker build -f Dockerfile.firewall-allow -t $REPO_NAME/vic-machine-firewall-allow:$VERSION .
docker build -f Dockerfile.firewall-deny -t $REPO_NAME/vic-machine-firewall-deny:$VERSION .
docker build -f Dockerfile.dumpargs -t $REPO_NAME/vic-machine-dumpargs:$VERSION .
rm Dockerfile*

