# Purpose of this Dockerfile is to create a VIC image that runs nested Docker that can be accessed remotely
# You can use this image to build Docker images, general development, run tests etc.

# See README for more details

FROM vmware/photon

RUN tdnf install -y procps-ng iptables net-tools docker 1.12.6-1.ph1

EXPOSE 2376

CMD /usr/bin/dockerd -H tcp://0.0.0.0:2376 -s overlay2 $DOCKER_OPTS
