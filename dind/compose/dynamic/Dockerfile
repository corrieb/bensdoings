# Purpose of this Dockerfile is to create a VIC image that will run "docker-compose up" in a new nested Docker host
# The yml file is passed in dynamically when the containerVM is run, using -e COMPOSE_SCRIPT="$(cat docker-compose.yml)"
# This is functonally equivalent to a sealed appliance. There is no sshd and no remote Docker socket. 

# TODO: Have docker-compose down run on Docker stop

# See README for usage

FROM bensdoings/dind-photon

RUN curl -L https://github.com/docker/compose/releases/download/1.11.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
      && chmod +x /usr/local/bin/docker-compose

CMD [ "/etc/rc.local" ]

COPY rc.local /etc/

