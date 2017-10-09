VIC container VMs are a fantastic way to consume vSphere resource ephemerally. Advantages include:

 - Easy integration with the Jenkins Docker plugins (see HERE)
 - Container VMs only run when needed - they are not a resource reservation on your vSphere environment
 - Volume support makes it easy to cache dependencies between cVM invocations
 - NFS volume support is an excellent way to persist build artifacts or share dependencies between VMs
 - Slaves are not stateful. Any temporary data is automatically cleaned up when the build is complete.

While it's relatively easy to get Jenkins to drive VIC to do what you want, it's a little more complicated to set up a Jenkins slave with all of the necessary dependencies to support a successful build. Sure it's easy to demonstrate building Hello World, but what about more complex applications. In this README, we're going to look at some general principles and examples of how to create and configure Jenkins slaves.

**Requirements**

When it comes to building and configuring a Jenkins slave, there are a few requirements to consider. These include:

 - Dependencies. Ensuring the the correct artifacts are installed and configured in the slave
 - Data persistence. What data should be persisted, where should it go and what characteristics for the storage?
 - Security. How to secure the VIC endpoint and how to access Jenkins slaves securely
 - Resource management. How much compute resource should we devote to a Jenkins slave? How long should it run for?
 
 **Dependencies**
 
In trying to get away from Dependency Hell, we've created dependency management systems that themselves have dependencies and need to be correctly set up and configured. It's somewhat ironic that getting the dependencies and configuration right for dependency management systems can be somewhat tricky. 

_Where to Start_

Let's take Maven as an example (see below for a more detailed recipe for building Spring Boot with Maven). Installing Maven in a Dockerfile simply by piping curl to tar and copying a binary to somewhere in the path may not work. Then there's Java to consider - what version of Java does Maven support and what version does your project need? You don't want multiple versions of Java installed in your container image if you don't need them. Do you need a JDK or JRE? Then there might be git or subversion. What about userids? Environment variables? Locales? Do you need sshd running?

There's an existing image called `evarga/jenkins-slave` that is a reasonable generic place to start for a Jenkins slave. It has JRE, sshd and creates a jenkins user. This image works fine with VIC engine and will happily build Hello World for you. The main process it runs is  sshd which then kicks off Java child processes. So why not start from this image and create a Dockerfile that adds Maven, Git, Subversion and a JDK? I tried doing this and I ended up having difficulties that I wasn't willing to burn time to investigate. For a start, the Debian package manager insists on installing an old version of Maven and an older JDK. That's not what we need. The relationship between Maven, Java and the Guest is a complex one and the only way I could guarantee correct operation is to start from an official Maven image - which already has the correct JDK and Git - and add sshd and a jenkins user. 

So my first recommendation when building any Docker image is this: Think about what the core function of your image is and start with a parent image that best encapsulates that core function. In this particular instance, the core function is Maven, not sshd. So start from a Maven base image with the JDK and guest libraries you want and build up from there.

_Image Layers_

Every line in a Dockerfile presents as an image layer. These layers are not necessarily addressable as parent images, in fact they're really a caching optimization - an ability for the Docker engine to optimize builds. However, image layers add a small amount of overhead in production, both in terms of how long it takes to pull images and datastore footprint. As such, it's trying to minimize the number of image layers where possible. For example, linking multiple lines together for a single RUN clause is a common practice. This will create a single image that encapsulates the output of all the commands run.

```
FROM Dockerfile

RUN this &&\
    that &&\
    the-other
```
Another tip to consider is if you start to get a lot of ENV clauses in the Dockerfile for environment variables. Note that you can combine them on the same line or you can create a script that gets run as part of the Dockerfile entrypoint.

_Environment Variables and sshd_

While we're on the topic of environment variables, it's important to remember that environment variables defined using ENV in a Dockerfile serve two purposes. One is for the build environment and the other is to set them for the main container process that's started. However, if the main container process is sshd, these environment variables apply to the sshd process, but not to any shell sessions that are opened with sshd. If you want to set environment variables for user shells, you will need to create a .bashrc or equivalent in the Dockerfile.

_Container Process_

As many of you will know, a container is capable of running more than one process. However, there is a single main process a container runs which is tied up with the container lifecycle. That main process can trigger child processes. There are various ways that child processes can be triggered in a container. 

 - Simply get an interactive shell into the container and start processes from the shell. This doesn't lend itself to automation
 - One is to use the `docker exec` command. This works well if you need to start a "sidecar" process on demand, such as a shell or command
 - Make sshd the main container process. That forces the container to a role where it only serves sshd requests
 - Create an init script with a trap handler or use an init process such as [this script](dind/with-ssh/rc.local) or [tini](https://github.com/krallin/tini)

The Jenkins Docker Plugin has standardized on using sshd. You can see the advantages - it's a well-known protocol, it has built-in authentication, the user is meaningful to the guest OS and it works well for long-running slaves. The alternative would be a Jenkins plugin that launches the build command on the container itself. While this might be a cleaner abstraction, it doesn't allow for multiple sessions, it makes it harder to get into the build slave when the build has finished (the container would be stopped) and it doesn't work for container reuse, if that is desired.

_Getting it Right_

Once you've done this, there may be considerable trial and error involved to get everything correctly configured. There certainly was for me in getting Spring Boot to build. The simplest approach to this is to start by attaching to your build slave interactively as root, Eg. 'docker run -it build-slave /bin/bash'. This ensures that all the environment variables from the Dockerfile are set, you won't have permissions issues and you can debug and re-try as needed. Every time you make a change that moves you further on, add that change to the Dockerfile, push, pull and re-test.

Once you have success running as root in a shell, try the same thing running as the ssh user and re-configure as necessary.

**Data Persistence**




