# Purpose of this Dockerfile is to create a VIC image that runs nested Docker that can be accessed remotely
# You can use this image to build Docker images, general development, run tests etc.

# See README for usage

FROM debian:jessie
 
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get -yy -q install \
    curl \
    apt-transport-https \
    gnupg2 \
    && apt-key adv \
    --keyserver hkp://ha.pool.sks-keyservers.net:80 \
    --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
    && echo "deb https://apt.dockerproject.org/repo debian-jessie main" >> /etc/apt/sources.list.d/docker.list \
    && DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get -yy -q install docker-engine

EXPOSE 2376

CMD /usr/bin/dockerd -H tcp://0.0.0.0:2376 $DOCKER_OPTS
