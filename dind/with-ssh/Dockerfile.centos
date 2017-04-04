# Note that this doens't work on VIC 0.9.0 due to https://github.com/vmware/vic/issues/3858

FROM bensdoings/dind-centos-local:17.03.1-ce

# Adds vim and net-tools (for ifconfig) - once you have a shell, you often want these
# You can set the root passwd after deployment to "foobar" using docker exec
#   Eg. docker exec -d myContainer /usr/sbin/usermod --password $(echo foobar | openssl passwd -1 -stdin) root

RUN yum install -y \
    openssh-server \
    sudo \
    vim \
    net-tools \
    openssl \
    && mkdir /var/run/sshd && chmod 700 /var/run/sshd \
    && /usr/bin/ssh-keygen -A \
# Comment out next 3 lines if you do not want to bake in a particular non-root user/pwd combo
    && useradd -s /bin/bash -m -p $(openssl passwd -1 vmware) vmware \
    && su vmware && mkdir ~/.ssh && chmod 700 ~/.ssh \
    && echo "vmware   ALL=(ALL:ALL) ALL" >> /etc/sudoers \
# Comment out if you don't want to grant root ssh access
    && sed -i -- 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config

EXPOSE 22

CMD /usr/sbin/sshd && /usr/bin/dockerd -s overlay2 $DOCKER_OPTS
