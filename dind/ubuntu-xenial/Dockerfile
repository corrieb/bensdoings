# Purpose of this Dockerfile is to create a VIC image that runs nested Docker that can be accessed remotely
# You can use this image to build Docker images, general development, run tests etc.

# Note that this doens't work on VIC 0.9.0 due to https://github.com/vmware/vic/issues/3858

# See README for usage

FROM ubuntu:xenial

RUN apt-get update -y \
    && apt-get -yy install \
       apt-transport-https \
       ca-certificates \
       curl \
       software-properties-common \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable" \
    && apt-get update -y \
    && apt-get -yy -q install docker-ce

EXPOSE 2376

CMD /usr/bin/dockerd -H tcp://0.0.0.0:2376 -s overlay2 $DOCKER_OPTS
