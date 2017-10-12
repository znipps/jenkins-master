FROM ubuntu:xenial
MAINTAINER Bilal Sheikh <bilal@techtraits.com>

RUN apt-get update && apt-get -y upgrade && apt-get -y install software-properties-common && add-apt-repository ppa:webupd8team/java -y && apt-get update

# expose the port
EXPOSE 8080
# required to make docker in docker to work
VOLUME /var/lib/docker

RUN (echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && apt-get install -y oracle-java8-installer oracle-java8-set-default

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH

# default jenkins home directory
ENV JENKINS_HOME /var/jenkins
# set our user home to the same location
ENV HOME /var/jenkins

# set our wrapper
ENTRYPOINT ["/usr/local/bin/docker-wrapper"]
# default command to launch jenkins
CMD java -jar /usr/share/jenkins/jenkins.war

# setup our local files first
ADD docker-wrapper.sh /usr/local/bin/docker-wrapper

# for installing docker related files first
RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list
# apparmor is required to run docker server within docker container
RUN apt-get update -qq && apt-get install -qqy wget curl git iptables ca-certificates apparmor

# for jenkins
RUN echo deb http://pkg.jenkins-ci.org/debian binary/ >> /etc/apt/sources.list \
    && wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN apt-get update -qq && apt-get install -qqy jenkins

# now we install docker in docker - thanks to https://github.com/jpetazzo/dind
# We install newest docker into our docker in docker container
RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz \
  && tar --strip-components=1 -xvzf docker-latest.tgz -C /usr/local/bin \
  && chmod +x /usr/local/bin/docker
