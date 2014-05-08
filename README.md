# Run Jenkins builds that use docker

This is a docker image that contains Jenkins, and has the ability to run docker, itself, inside docker!
(crazy, I know).

    
    docker run -p 8080:8080 --privileged --name jenkins-1 virtualpost/jenkins-docker-executors


This will download, and then run Jenkins in a docker container - on port 8080. 

You can see your docker conatiner running with:

    docker ps

If you with to use a volume outside to store your workspace, you can with bind mounting and setting the JENKINS_HOME directory. 

Also, you can create (data containers)[http://docs.docker.io/use/working_with_volumes/] to store jenkins data, which should correspond to the JENKINS_HOME.  An example of using data containers would be something like:

    docker run --name JENKINS_DATA -v /home/jenkins busybox true
    docker run --privileged -d -e JENKINS_HOME=/home/jenkins --volumes-from JENKINS_DATA -p 8080:8080 --name jenkins-1 virtualpost/jenkins-docker-executors

This will allow you to persist your jenkins data across container restarts.  In addition, you will also be able to attach the data container to make backups separately from the jenkins contains

If you wish to use docker in a build - you can. You can just use the `docker` command from a freestyle build, it will work just like expect it would. Don't do anything crazy like try to run this thing itself inside docker, as then you end up in an inception like world and ultimate in limbo. http://inception.davepedu.com/ ;)

This works via the exellent work covered here https://github.com/jpetazzo/dind


