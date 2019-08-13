# Ubuntu 16.04 LTS
# OpenJDK 8
# Maven 3.2.2
# Jenkins 2.176.2
# Git
# Nano

# pull base image Ubuntu 16.04 LTS (Xenial)
# FROM ubuntu:xenial
FROM ubuntu@sha256:97b54e5692c27072234ff958a7442dde4266af21e7b688e7fca5dc5acc8ed7d9

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# install the OpenJDK 8 java runtime environment and curl
RUN apt update; \
  apt upgrade -y; \
  apt install -y default-jre curl wget git nano; \
  apt-get clean

ENV JAVA_HOME /usr
ENV PATH $JAVA_HOME/bin:$PATH


##-- Maven --
# get maven 3.2.2 and verify its checksum
RUN wget --no-verbose -O /tmp/apache-maven-3.2.2.tar.gz http://archive.apache.org/dist/maven/maven-3/3.2.2/binaries/apache-maven-3.2.2-bin.tar.gz; \
  echo "87e5cc81bc4ab9b83986b3e77e6b3095 /tmp/apache-maven-3.2.2.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.2.2.tar.gz -C /opt/; \
  ln -s /opt/apache-maven-3.2.2 /opt/maven; \
  ln -s /opt/maven/bin/mvn /usr/local/bin; \
  rm -f /tmp/apache-maven-3.2.2.tar.gz
ENV MAVEN_HOME /opt/maven


##-- Jenkins --
ARG user=jenkins
## ARG group=jenkins
## ARG uid=1000
## ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/lib/jenkins

ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}

# We can use docker run command with
#   -v /etc/group:/etc/group:ro
#   -v /etc/passwd:/etc/passwd:ro
# options to share user/group IDs both Host OS and container.
#
## # Jenkins is run with user `jenkins`, uid = 1000
## # If you bind mount a volume from the host or a data container,
## # ensure you use the same uid
## RUN mkdir -p $JENKINS_HOME \
##   && chown ${uid}:${gid} $JENKINS_HOME \
##   && groupadd -g ${gid} ${group} \
##   && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# `/usr/share/jenkins/ref/` contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d

# jenkins version being bundled in this docker image
ARG JENKINS_VERSION
ENV JENKINS_VERSION ${JENKINS_VERSION:-2.176.2}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=33a6c3161cf8de9c8729fd83914d781319fd1569acf487c7b1121681dba190a5

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
#ADD http://mirrors.jenkins.io/war-stable/latest/jenkins.war /opt/jenkins.war

ADD ${JENKINS_URL} /usr/share/jenkins/jenkins.war
RUN echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -
RUN chmod 644 /usr/share/jenkins/jenkins.war

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
# RUN chown -R ${user} "$JENKINS_HOME" /usr/share/jenkins/ref

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# configure the container to run jenkins, mapping container port 8080 to that host port
#ENTRYPOINT ["java", "-jar", "/usr/share/jenkins/jenkins.war"]
EXPOSE 8080

#CMD [""]
