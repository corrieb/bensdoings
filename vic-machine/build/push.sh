#!/bin/bash

REPO_NAME="bensdoings"
VERSION="1.1.0"

docker push $REPO_NAME/vic-machine-create:$VERSION
docker push $REPO_NAME/vic-machine-debug:$VERSION
docker push $REPO_NAME/vic-machine-delete:$VERSION
docker push $REPO_NAME/vic-machine-inspect:$VERSION
docker push $REPO_NAME/vic-machine-ls:$VERSION
docker push $REPO_NAME/vic-machine-rollback:$VERSION
docker push $REPO_NAME/vic-machine-upgrade:$VERSION
docker tag $REPO_NAME/vic-machine-create:$VERSION $REPO_NAME/vic-machine-create:latest
docker tag $REPO_NAME/vic-machine-debug:$VERSION $REPO_NAME/vic-machine-debug:latest
docker tag $REPO_NAME/vic-machine-delete:$VERSION $REPO_NAME/vic-machine-delete:latest
docker tag $REPO_NAME/vic-machine-inspect:$VERSION $REPO_NAME/vic-machine-inspect:latest
docker tag $REPO_NAME/vic-machine-ls:$VERSION $REPO_NAME/vic-machine-ls:latest
docker tag $REPO_NAME/vic-machine-rollback:$VERSION $REPO_NAME/vic-machine-rollback:latest
docker tag $REPO_NAME/vic-machine-upgrade:$VERSION $REPO_NAME/vic-machine-upgrade:latest
docker push $REPO_NAME/vic-machine-create:latest
docker push $REPO_NAME/vic-machine-debug:latest
docker push $REPO_NAME/vic-machine-delete:latest
docker push $REPO_NAME/vic-machine-inspect:latest
docker push $REPO_NAME/vic-machine-ls:latest
docker push $REPO_NAME/vic-machine-rollback:latest
docker push $REPO_NAME/vic-machine-upgrade:latest

