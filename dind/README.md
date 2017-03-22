The purpose of these Dockerfiles is to create VIC images that run nested Docker that can be accessed remotely. The net result of running one of these images in VIC is a fully-functional Docker daemon running in a VM with its own image cache, bridge network etc. 

This does not come with the same caveats as running Docker in *actual* Docker. The Docker engine in these VMs is as fully functional as any other. The beauty of this is that we can treat a Docker host as ephemerally as a container.

These Dockerfiles are very easy to extend to add your own functionality. 

(Note that only the Photon versions are the only ones that work on VIC 0.9.0 due to https://github.com/vmware/vic/issues/3858)

**Usage**

You can use these images if you want a simple way to spin up Docker hosts on vSphere using VIC. They're useful for building other Docker images, general development, run tests, play with Swarm etc.

**Build**

Build Dockerfile with regular Docker using: 
``docker build -t <registry>/<imageid:version> .``

Push to a registry: 
``docker login <registry>; docker push <registry>/<imageid:version>``

Example:

```
# Using a local Docker installation

docker build -t 10.118.69.100/test/debian-dind:1.13.1 .
docker push 10.118.69.100/test/debian-dind:1.13.1
```

Or if you simply want to use the versions I built:

```
docker pull bensdoings/dind-photon:1.12.6
docker pull bensdoings/dind-debian:1.13.1
```

**Run with Public IP**

This starts a Docker host with an IP address on the public vSphere network assigned to the Virtual Container Host
(Note that this assumes that the public network was added on VCH creation as a ``--container-network``)

``docker run -d -net=<vsphere-public-network> <registry>/<imageid:version>``

Find IP address of the deployed VM: ``docker inspect <containerid> | grep IPAddress``

Run a test container in new Docker host: ``docker -H <ipaddress>:2376 run --rm hello-world``

Example:

```
# Start by talking to the VIC endpoint - note we name the container in this example and use the name in inspect
export DOCKER_HOST=<vic-endpoint-ip:port>
docker run -d --name=dind-test --net=ExternalNetwork 10.118.69.100/test/debian-dind:1.13.1
docker inspect dind-test | grep IPAddress

# Now you can talk to the nested Docker endpoint
docker -H 10.118.69.89:2376 run --rm hello-world
```

**Run with Port Mapping**

This is variation on the above example, except in this case, the Docker host does not get an identity on the public network. As such, you need to address it using port mapping on the VIC endpoint IP. In this example, we pick port 10001.

``docker run -d -p 10001:2376 <registry>/<imageid:version>``

Run a test container in new Docker host: 
``docker -H <vic-endpoint-ip>:10001 run --rm hello-world``

**Setting memory and CPU on the Docker host**

Add ``-m <mem> and --cpuset-cpus <vcpus>`` on the docker command-line to set resource constraints for the docker host

Example:

```
docker run -d --cpuset-cpus 4 -m 4g --net=ExternalNetwork 10.118.69.100/test/photon-dind:1.12
```

**Alternative to using docker -H**

For simplicity, you can set ``DOCKER_HOST=<ipaddress:port>`` instead of using ``-H`` on the docker command

**Passing options through to the Docker daemon**

Note that in the Dockerfiles, ``$DOCKER_OPTS`` is added as an environment variable. That means you can simply pass options to the Docker daemon via the command that starts the Docker host using the ``-e`` flag. This is particularly useful for things like setting an insecure registry to pull from.

Example:

```
docker run -e DOCKER_OPTS='--insecure-registry 10.118.69.100' -d --net=ExternalNetwork 10.118.69.100/test/photon-dind:1.12
docker -H 10.118.69.85:2376 pull 10.118.69.100/test/foobedoo
```

**Run Docker locally with SSH server**

If you'd prefer to login to a new Docker host and run Docker locally, there's an example Dockerfile in ``/with-ssh/``. 

Using sshd is more convenient than starting the container with a shell using ``docker run -it`` because if you exit such a container, it will shut down. You would also have to remember to start the docker daemon manually each time.

This example image is set up with a default user and password of vmware/vmware - so obviously you may want to consider changing that

Example:

```
docker run -d --name=dind-test-ssh --net=ExternalNetwork bensdoings/dind-debian-ssh:1.13.1
docker inspect dind-test-ssh | grep IPAddress
ssh vmware@10.118.69.47
vmware@8540f8071200:~$ sudo docker run busybox date
```

**Persist local state between invocations**

If you want your nested Docker hosts to be particularly short-lived, but preserve the image cache and container state in between invocations, you can create a volume and mount it to /var/lib/docker. This is particularly useful in the case of Docker build or running some tests, where you may want the VM to exist only for the duration of the build or test, to save resources.

Behind the scenes, this will create a formatted VMDK that's mounted as a disk to the location specified. The VMDK can only be mounted to one containerVM at a time. 

Example:

```
docker volume create --name images
docker run -d -v images:/var/lib/docker --name=dind-test -p 10001:2376 bensdoings/dind-debian:1.13.1
docker -H 10.118.69.50:10001 pull busybox
# Note Docker will pull busybox to the empty volume

docker kill dind-test
docker rm dind-test

docker run -d -v images:/var/lib/docker --name=dind-test -p 10001:2376 bensdoings/dind-debian:1.13.1
docker -H 10.118.69.50:10001 pull busybox
# Note busybox image is already there
```

**Docker Build Scenarios**

VIC engine itself does not currently support Docker build, but the simplicity of being able to run builds in a nested Docker host - particularly with the speed and efficiency of an overlay fileysystem in a single VMDK, makes this an attractive option. This section explores some simple techniques to using nested Docker hosts for Docker build.

1. Basic Scenario

Simply running the nested Docker host in dameon mode and setting DOCKER_HOST to the address of the nested Docker engine works really well. This is because the remote Docker client will automatically send the whole build context (the current directory tree) to the VM, unpack it and run Docker build on it. The result will exist in the local image cache, but can then easily be pushed to a registry.

As an example, let's build a trivial Dockerfile using a nested Docker host, push it to DockerHub and then run it in VIC.

```
docker run -d -p 10001:2376 --name dind-test bensdoings/dind-debian:1.13.1
echo -e "FROM busybox\n\nCMD echo \"Hello Ben\"" > Dockerfile

# Set the Docker client to point at the new nested host
export DOCKER_HOST=10.118.69.50:10001

# I usually run docker ps at this point to wake up and initialize the daemon
docker ps

# Build and test the new Dockerfile
docker build -t bensdoings/silly-test .
docker run bensdoings/silly-test
> Hello Ben

# Make sure I'm logged in to Docker Hub
docker login
docker push bensdoings/silly-test

# Now switch the Docker client back to the main Docker endpoint exposed by VIC
# Note that it's just a different port on the same IP because we used Port Mapping above
export DOCKER_HOST=10.118.69.50:2375
docker run bensdoings/silly-test

# VIC should now download the Docker image from Docker Hub and run the command in a busybox containerVM

# Clean up
docker kill dind-test
docker rm dind-test
```

**Creating a Sealed Appliance with Docker Compose**

The whole purpose of Docker Compose is to download one or more images and then spin up containers, volumes, networking etc. The idea is that you should be able to create an application from a number of containerized services which are tightly-coupled in some way. VIC itself is supporting the Compose capabilities to allow you to spin up multiple containerVMs with vSphere networking, storage etc.

As such, when you combine native Docker Compose with the VIC nested Docker model, you can create a sealed appliance with no SSH access, no remote Docker API and just have it bootstrap from the Compose file after booting. 

There are two ways this can be achieved, the dynamic way and the static way. 

1. Dynamic

The dynamic method involves passing the Compose file to the containerVM as part of the ``docker create`` or ``docker run`` commands. The dynamic method implies subsequent pulling of the requisite images before the application can start, unless a persistent volume is used for the image cache (see above).

An example Dockerfile demonstrating the dynamic method is in ``/compose/dynamic``. It adds docker-compose binaries to the existing Photon dind image. The command serializes the yml to a file, starts the Docker engine, waits for it to start and then runs ``docker-compose up``. The lifespan of the containerVM is tied to the lifespan of the docker-compose process.

As an example, let's run the Docker Wordpress demo

```
# Start by creating a docker-compose.yml locally. See https://docs.docker.com/compose/wordpress/#define-the-project

# Then pass in the contents of the compose file as an environment variable
# Note that we're exporting port 8000, which is defined in the example Compose file as the HTTP port
# Note also that if you miss out the -d, you will attach to the output of docker-compose itself. This is OK, but ctrl-C doesn't work
# As with previous examples, we can pass options to the Docker engine with DOCKER_OPTS

docker run --name compose-test -d -p 8000:8000 -e COMPOSE_SCRIPT="$(cat docker-compose.yml)" bensdoings/dind-compose-dynamic

# To see the output of docker-compose

docker logs compose-test

# Once the application has fully initialized, test for Wordpress home page on endpoing VM at port 8000

wget 10.118.69.163:8000
```
Congratulations! With a single line, you've created a VM that's running a fully functional Wordpress with a nested mysql database. 

(In reality, if you were running this in production, there's a strong case for running the Wordpress instance and database in separate VMs - not least for runtime isolation. If so, you can target VIC directly with docker-compose).

2. Static

The static method involves baking the Compose file into a Dockerfile and the image data can also be cached inside the containerVM Docker images for faster startup or if behind a firewall. This is a true sealed appliance in that it can only ever bootstrap as one thing.

TBD
