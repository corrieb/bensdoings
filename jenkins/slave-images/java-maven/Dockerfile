FROM openjdk:8-jdk

# Copied mostly from https://github.com/carlossg/docker-maven/blob/master/jdk-8/settings-docker.xml

ARG JENKINS_USER="jenkins"
ARG JENKINS_PWD="jenkins"

ARG MAVEN_VERSION=3.5.0
ARG USER_HOME_DIR="/home/${JENKINS_USER}"
ARG MAVEN_REPO="${USER_HOME_DIR}/.m2"
ARG SHA=beb91419245395bd69a4a6edad5ca3ec1a8b64e41457672dc687c173a495f034
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

COPY settings-docker.xml /usr/share/maven/ref/

# Maven image customization for Jenkins, build and add mvnw, sshd and set locales

RUN apt-get update && apt-get install -y openssh-server locales &&\
    # Maven wrapper doesn not set itself up by default to run as any user other than root, so set perms. Also delete the build dir.
    mvn -N io.takari:maven:wrapper && chmod -R 755 /mvnw /.mvn && mv /mvnw /usr/local/bin && rm -fr /root/.m2 &&\
    # Need to ensure that locales are available for correct operation of tests
    locale-gen en_US.UTF-8 &&\
    # Set up sshd and the userid
    mkdir /var/run/sshd && chmod 700 /var/run/sshd &&\
    useradd -m -d ${USER_HOME_DIR} -s /bin/bash ${JENKINS_USER} &&\
    su -c "mkdir ${MAVEN_REPO}" ${JENKINS_USER} &&\
    echo "${JENKINS_USER}:${JENKINS_PWD}" | chpasswd

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=C

# Standard SSH port
EXPOSE 22

# Add the VOLUME last to ensure that the mount point is created and has the correct permissions for the Jenkins user 
VOLUME ${MAVEN_REPO}

CMD ["/usr/sbin/sshd", "-D"]

# Add any environment variables for the Jenkins user
COPY .bashrc ${USER_HOME_DIR}
