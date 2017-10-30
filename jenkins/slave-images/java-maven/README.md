This is a slave image that I've successfully configured to build the Spring Boot project. This took longer to get right than I would have expected, but the whole point of a Docker image is that someone else has done all the hard work so you don't have to!

 - I'll start by taking you through the Dockerfile. What's in it and why it's configured in the way it is.
 - Next I'll show you how to test the Slave outside of Jenkins
 - Finally, I'll show you how to configure Jenkins to build Spring Boot using the slave.
 
 **Dockerfile**

First question is where to start from. What parent image to inherit from? See HERE for a general discussion on the topic with examples of issues I had with this particular slave. For Spring Boot I needed a particular version of Maven and Java with dependencies then added in. The `library/maven` image seemed like the most appropriate place to start, but it presumed I wanted to run as root and forced anonymous volumes on me, so I decided to copy the bits I needed from the Dockerfile for that image and inherit from its `openjdk` parent.

You'll see in this particular version, I've used a hard-coded obvious SSH password. Yes this is bad. It's what every other image does. I will discuss ways to improve on this in a different section.

The Maven Wrapper that Spring Boot uses was one of the things I struggled with. It won't install as a non-root user because it expects to be able to create hidden folders and a binary in the root of the filesystem. It also uses Maven to install itself, so the moment you install it as root, you get a `/root/.m2` that you don't want.

Java, Spring and Maven appear to be sensitive to locale settings, so that took a bit of trial and error to get right. Note that I've set the locale environment variables both in the Dockerfile and in the .bashrc file. Environment variables set in the Dockerfile apply to the `sshd` binary, but don't apply to any shells that get created when users create a session. That's why you need the .bashrc file to ensure that the environment for the Jenkins user is correct.

Note that if you want to be able to read or write to a volume mount as a non-root user, the directly needs to exist in the Docker image with the correct permissions before the mount is performed on container start. That's why you'll see the explicit creation of `/home/jenkins/.m2' as the Jenkins user to ensure that it has the correct permissions.

Finally note that the main container process is `/usr/sbin/sshd` configured to run in blocking mode. This is as good as anything frankly - the main role of the container is to marshal sessions over SSH.

**Building and pushing**

Using vanilla Docker configured to push to a registry that can be seen by the VCH, run the following command:

```
~$ cd bensdoings/jenkins/slave-images/java-maven/
~/bensdoings/jenkins/slave-images/java-maven$ sudo docker build -t <registry-address>/<project>/jenkins-slave-maven .
~/bensdoings/jenkins/slave-images/java-maven$ sudo docker push <registry-address>/<project>/jenkins-slave-maven
```
If you can't push to the registry, make sure that you have the registry certificate in `/etc/docker/certs.d/<registry-address/`, that you've logged in to the registry using `docker login <registry-address>` and that you're authorized to push to it.

If you push this image to the VIC registry, you'll see it's riddled with vulnerabilities that have been inherited from the base Debian image. This is a topic for another day.

**Testing**

I'm going to test in VIC, rather than vanilla Docker, because that's the environment we're expecting Jenkins to use. I'm going to pull the image I just built and pushed to my local VIC registry. I'm also going to keep the Docker run command as simple as possible.

```
~$ docker network create jenkins
~$ docker run --name test-slave --net jenkins -d -p 22 <registry-address>/<project>/jenkins-slave-maven
~$ docker ps
~$ docker inspect test-slave
~$ docker exec test-slave df
~$ docker exec test-slave ps
```
Note that this assumes you have a default volume store configured in your VCH. If not, you'll need to create a volume and explictly add it to the docker run command with `-v <volume-name>:/home/jenkins/.m2`. You'll want to do this anyway at some point (see below).

Note that once I ran the slave, I ran a bunch of commands to check that it's doing what I expect. 
 - The `docker ps` command shows that it's running and gives me the port mapping for the SSH client
 - The `docker inspect` command shows that I have an anonymous volume created that's been mounted at /home/jenkins/.m2. 
 - The `df` command executed in the guest shows that the volume mounted is 1GB in size - this may not be big enough for our maven repo!
 - Running `ps` shows the processes running in the guest
 
Let's try logging in using SSH. The port mapping displayed by `docker ps` was `10.118.68.250:32995->22/tcp`, so we need to specify port 32995 with our SSH client. Now of course the password is `jenkins`.

```
~$ ssh jenkins@10.118.68.250 -p 32995
jenkins@1f3cdcf7d0d6:~$ git clone https://github.com/spring-projects/spring-boot.git
jenkins@1f3cdcf7d0d6:~$ cd spring-boot
jenkins@1f3cdcf7d0d6:~$ mvnw clean install
```
Note that the instructions on the build command and the URL for the git clone command came directly from https://github.com/spring-projects/spring-boot.

Assuming this ran successfully (and why wouldn't it? Works for me!) you should see the build process download a large number of dependencies into the maven repo. This is the 1GB mounted VMDK volume that would have been created in the default volume store.

So... how did it go?

Well, actually it crashed for me first time around running a test. This is the trial and error part. What went wrong?

```
[ERROR] org.apache.maven.surefire.booter.SurefireBooterForkException: The forked VM terminated without properly saying goodbye. VM crash or System.exit called?
```
Hmm. Well, seems like maybe the 2GB default memory allocation for this container isn't enough if the test environment is going to be starting multiple JVMs. Let's exit the slave, shut it down and restart it with more memory. We can't be sure that this is the problem, but that's the nature of trial and error.

```
jenkins@1f3cdcf7d0d6:~$ exit
~$ docker rm -f test-slave
```
Another frustration is that the next time we start this slave, it's going to have to rebuild its maven repository from scratch - and there was concern about the default volume size being too small. So let's also create a named and sized volume we can re-use through invocations.

```
~$ docker volume create --opt VolumeStore=vsan --opt Capacity=5G jenkins-slave-maven-repo
~$ docker run -m 4g -v jenkins-slave-maven-repo:/home/jenkins/.m2 --name test-slave --net jenkins -d -p 22 <registry-address>/<project>/jenkins-slave-maven
~$ docker ps
~$ ssh jenkins@10.118.68.250 -p 32997
jenkins@1f3cdcf7d0d6:~$ git clone https://github.com/spring-projects/spring-boot.git
jenkins@1f3cdcf7d0d6:~$ cd spring-boot
jenkins@1f3cdcf7d0d6:~$ mvnw clean install
```

**Integrating into Jenkins**

Now that we've shown that the build *should* work via an SSH session as the `jenkins` user, let's configure the Jenkins Docker plugin to run this slave in response to commits to the Spring Boot GitHub repo.

_Configure a Docker Cloud_

See generic instructions HERE for the plugins and configuration required to set up a Docker Cloud to talk to a VCH. 

Once that's configured and set up, you'll need to configure a Docker Agent template that the Spring Boot project will use. Here are the settings I used for the template:

```
Labels: maven
Docker Image: <registry-address>/<project>/jenkins-slave-maven
Docker Command: /usr/sbin/sshd -D
Network: jenkins-net
Volumes: jenkins-slave-maven-repo:/home/jenkins/.m2
Memory Limit in MB: 4096
Instance Capacity: 1
Availability: Docker Once Retention Strategy with 10m timeout
Executors: 1
Launch Method: Docker SSH computer launcher
Credentials: jenkins/jenkins (need to configure in Jenkins credentials management)
Host Key Verification Strategy: Known Hosts File Verification Strategy
Remote FS Root Mapping: /var/jenkins_home
Pull Strategy: Pull Once and Update Latest
```

All of the options above should be pretty obvious. Note the important factor that the use of the named volume means that we cannot have multiple instances of this template running concurrently. Neither can you choose shared RW storage because a Maven repo itself needs exclusive access. See the discussion HERE.

_Create the Project_

For simplicity, we'll create a FreeStyle project called "spring-boot-master". We then need to configure the project. 

```
Restrict where this project can be run: maven (this is the label we set up on the template above - should be offered in a drop down)
Source Code Management: Git
 - Repository URL: `https://github.com/spring-projects/spring-boot.git`
Add a Build Step: Execute Shell
 - Command: `mvnw clean install`
```
Once you've added these custom fields, hit the "Build Now" button and see what happens. Note that the first time you run it, your VCH may be pulling the slave image and this may take some time. If you suspect something is wrong with launching the container VM, you can see the Docker plugins output in the general Jenkins system log file.

If a slave does come up, but then quickly goes away again or becomes inactive, there's likely something wrong with they way you've authenticated to it. Check the Jenkins log file.

Once the slave comes up and connects, if the build fails, you can investigate the reasons why in the job log file.




