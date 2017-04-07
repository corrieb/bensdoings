# Purpose of this Dockerfile is to create a VIC image that runs nested Docker that can be accessed remotely
# You can use this image to build Docker images, general development, run tests etc.

# See README for more details

FROM vmware/photon

RUN tdnf install --refresh -y procps-ng iptables net-tools 

# Install supported version
RUN tdnf install --refresh -y docker 1.12.6-1.ph1
# Install unsupported version
# RUN curl -L'#' https://get.docker.com/builds/Linux/x86_64/docker-17.03.1-ce.tgz | tar --strip-components=1 -C /usr/bin -xzf -

EXPOSE 2376

CMD /usr/bin/dockerd -H tcp://0.0.0.0:2376 -s overlay2 $DOCKER_OPTS
