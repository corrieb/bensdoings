#FROM <my-vic-registry-ip>/default-project/dch-photon:1.13 
FROM vmware/dch-photon:1.13

ARG JENKINS_USER="jenkins"
ARG JENKINS_PWD="jenkins"
ARG USER_HOME_DIR="/home/${JENKINS_USER}"

RUN tdnf install --refresh -y openssh vim git sudo make openjre.x86_64 &&\
    mkdir -p /var/run/sshd && chmod 700 /var/run/sshd &&\
    useradd -m -d ${USER_HOME_DIR} -s /bin/bash ${JENKINS_USER} &&\
    echo "${JENKINS_USER}:${JENKINS_PWD}" | chpasswd &&\
    echo "${JENKINS_USER}   ALL = NOPASSWD : ALL" >> /etc/sudoers

# Standard SSH port
EXPOSE 22

CMD [ "/etc/rc.local" ]

# Add any environment variables for the Jenkins user
COPY .bashrc ${USER_HOME_DIR}
COPY rc.local /etc
ENTRYPOINT []
