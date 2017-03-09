The purpose of these Dockerfiles is to create VIC images that run nested Docker that can be accessed remotely. The net result of running one of these images in VIC is a fully-functional Docker daemon running in a VM with its own image cache, bridge network etc. 

This does not come with the same caveats as running Docker in *actual* Docker. The Docker engine in these VMs is as fully functional as any other. The beauty of this is that we can treat a Docker host as ephemerally as a container.

These Dockerfiles are very easy to extend to add your own functionality. 

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
