# Purpose of this Dockerfile is to create a VIC image that will run "docker-compose up" in a new nested Docker host
# The yml file should be built into a child image of the following form:

# FROM bensdoings/dind-compose-static
# COPY docker-compose.yml /

# This is functonally equivalent to a sealed appliance. There is no sshd and no remote Docker socket.

# See README for more usage

FROM bensdoings/dind-photon:1.12.6

COPY run.sh /

RUN curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
      && chmod +x /usr/local/bin/docker-compose

CMD  nohup /usr/bin/dockerd -s overlay2 $DOCKER_OPTS > /tmp/docker.out 2>&1 & \
        while [ ! -S /var/run/docker.sock ]; do sleep 2; done && \
        docker-compose up

