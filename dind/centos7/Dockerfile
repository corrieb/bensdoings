# Purpose of this Dockerfile is to create a VIC image that runs nested Docker that can be accessed remotely
# You can use this image to build Docker images, general development, run tests etc.

# Note that this doens't work on VIC 0.9.0 due to https://github.com/vmware/vic/issues/3858

# See README for usage

FROM centos:7.3.1611

RUN yum install -y yum-utils \
    && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
    && yum makecache fast \
    && yum install -y docker-ce

EXPOSE 2376

CMD [ "/etc/rc.local" ]

COPY rc.local /etc/

