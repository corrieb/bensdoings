# Note that this doens't work on VIC 0.9.0 due to https://github.com/vmware/vic/issues/3858

FROM bensdoings/dind-debian:1.13.1

# Adds vim and net-tools (for ifconfig) - once you have a shell, you often want these
# Remove the last time if you don't want to grant root ssh access

RUN DEBIAN_FRONTEND=noninteractive apt-get -yy -q install \
    openssh-server \
    sudo \
    vim \
    net-tools \
    && mkdir /var/run/sshd && chmod 700 /var/run/sshd \
    && useradd -s /bin/bash -m -p $(openssl passwd -1 vmware) vmware \
    && su vmware && mkdir ~/.ssh && chmod 700 ~/.ssh \
    && echo "vmware   ALL=(ALL:ALL) ALL" >> /etc/sudoers \
    && sed -i -- 's/without-password/yes/g' /etc/ssh/sshd_config

EXPOSE 22

CMD /usr/sbin/sshd && /usr/bin/dockerd -s overlay2 $DOCKER_OPTS
