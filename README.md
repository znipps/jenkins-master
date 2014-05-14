# Run Jenkins builds that use docker

This is a docker image that contains Jenkins, and has the ability to run docker, itself, inside docker!
(crazy, I know).

    
    docker run -p 8080:8080 --privileged --name jenkins-1 virtualpost/jenkins-docker-executors


This will download, and then run Jenkins in a docker container - on port 8080. 

You can see your docker conatiner running with:

    docker ps

If you with to use a volume outside to store your workspace, you can with bind mounting and setting the JENKINS_HOME directory. 

Also, you can create (data containers)[http://docs.docker.io/use/working_with_volumes/] to store jenkins data, which should correspond to the JENKINS_HOME.  This image by default sets JENKINS_HOME to ```/var/jenkins```.  It can be overridden via the command line.

An example of using data containers would be something like:

    docker run --name JENKINS_DATA -v /var/jenkins busybox true
    docker run --privileged -d -e JENKINS_HOME=/var/jenkins --volumes-from JENKINS_DATA -p 8080:8080 --name jenkins-1 virtualpost/jenkins-docker-executors

This will allow you to persist your jenkins data across container restarts.  In addition, you will also be able to attach the data container to make backups separately from the jenkins container.

#### Jenkins User 

Jenkins runs as root user within the container.  By default, the root user home directory is set to /, but this has been overridden to be set to the same as JENKINS_HOME, which is ```/var/jenkins```.  This allows us to actually inject our own SSH keys, dockercfg file, and other OS-level config and authentication settings directly within the jenkins data volume so we can customize it separately should we need to.

#### Removing Container Data Volumes

This docker container requires mounting ```/var/lib/docker``` as a volume inside the container itself in order to run docker within docker.  The issue is that when you exit the docker container and remove the container, the data volume continues to exist.  This may take up an abnormal amount of space since you would assume that the data volume was cleared out after the container is stopped and removed. 

To properly remove the data volume created by the container, we would need to issue the command ```docker rm -v```.  The -v flag will properly remove volumes created by the container.

Alternatively, set the ```DOCKER_HOST``` environment to an external docker server that runs outside of the container, ie. the host system.  By using and accessing the host system, we remove the need to use a data volume for storing internal docker host.  This actually speeds up the creation of docker images by over 50% since we're not using vfs but the host system's storage engine.

#### Building/Running Docker Images Inside Jenkins Docker Container

If you wish to use docker in a build - you can. You can just use the `docker` command from a freestyle build, it will work just like expect it would. Don't do anything crazy like try to run this thing itself inside docker, as then you end up in an inception like world and ultimate in limbo. http://inception.davepedu.com/ ;)

This works via the exellent work covered here https://github.com/jpetazzo/dind


