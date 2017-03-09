FROM bensdoings/dind-debian:1.13.1

RUN DEBIAN_FRONTEND=noninteractive apt-get -yy -q install \
    openssh-server \
    sudo \
    && mkdir /var/run/sshd && chmod 700 /var/run/sshd \
    && useradd -s /bin/bash -m -p $(openssl passwd -1 vmware) vmware \
    && su vmware && mkdir ~/.ssh && chmod 700 ~/.ssh \
    && echo "vmware   ALL=(ALL:ALL) ALL" >> /etc/sudoers

EXPOSE 2376 22

CMD /usr/sbin/sshd && /usr/bin/dockerd -s overlay2 $DOCKER_OPTS
