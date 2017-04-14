# Adds vim and net-tools (for ifconfig) - once you have a shell, you often want these
# After deployment, you can use docker exec to configure sshd.
# 
# - Add a user and/or public key. Script will create the user if it doesn't exist
# docker exec -d myContainer /usr/bin/adduserkey derek "$(cat /home/derek/.ssh/id_rsa.pub)"
#
# - Set a password
# docker exec -d myContainer /usr/sbin/usermod --password $(echo foobar | openssl passwd -1 -stdin) root

FROM bensdoings/dind-photon

RUN tdnf install --refresh -y openssh net-tools vim sudo sed \
    && mkdir -p /var/run/sshd && chmod 700 /var/run/sshd \
    && sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config

# Uncomment to add a default user to the image
# RUN useradd -s /bin/bash -m -p $(openssl passwd -1 vmware) vmware \
#    && su vmware && mkdir ~/.ssh && chmod 700 ~/.ssh \
#    && echo "vmware   ALL=(ALL:ALL) ALL" >> /etc/sudoers

EXPOSE 2376 22

CMD [ "/etc/rc.local" ]

COPY rc.local /etc
COPY adduserkey /usr/bin

