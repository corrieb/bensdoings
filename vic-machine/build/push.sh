#!/bin/bash

REPO_NAME="bensdoings"
VERSION="latest"

docker push $REPO_NAME/vic-machine-create:$VERSION
docker push $REPO_NAME/vic-machine-debug:$VERSION
docker push $REPO_NAME/vic-machine-delete:$VERSION
docker push $REPO_NAME/vic-machine-inspect:$VERSION
docker push $REPO_NAME/vic-machine-ls:$VERSION
docker push $REPO_NAME/vic-machine-rollback:$VERSION
docker push $REPO_NAME/vic-machine-upgrade:$VERSION
