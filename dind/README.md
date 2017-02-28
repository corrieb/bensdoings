Purpose of these Dockerfiles is to create VIC images that run nested Docker that can be accessed remotely. The net result of running one of these images in VIC is a fully-functional Docker daemon running in a VM with its own image cache, bridge network etc. 

This does not come with the same caveats as running Docker in *actual* Docker. The Docker engine in these VMs is as fully functional as any other. The beauty of this is that we can treat a Docker host as ephemerally as a container.

These Dockerfiles are very easy to extend to add your own functionality. 

**Usage**

You can use these images if you want a simple way to spin up Docker hosts on vSphere using VIC. They're useful for building other Docker images, general development, run tests, play with Swarm etc.

**Build**

Build Dockerfile with regular Docker using: 
```docker build -t <registry>/<imageid> .```

Push to a registry: 
```docker login <registry>; docker push <registry>/<imageid>```

*Note: Docker commands for running the container need to target a VIC endpoint. Use ```DOCKER_HOST=<vch-ip:port>``` or ```docker -H <vch-ip:port>```*

Example:

```
# Using a local Docker installation

docker build -t 10.118.69.100/test/debian-dind-1.13.1 .
docker push 10.118.69.100/test/debian-dind-1.13.1
```

**Run with Public IP**

```docker run -d -net=<vsphere-public-network> <registry>/<imageid>```

Find IP address of the deployed VM: ```docker inspect <containerid> | grep IPAddress```

Run a test container in new Docker host: ```docker -H <ipaddress>:2376 run --rm hello-world```

Example:

```
# Start by talking to the VIC Docker endpoint - note we name the container in this example and use the name in inspect
export DOCKER_HOST=<vic-endpoint-ip:port>
docker run -d --name=dind-test --net=ExternalNetwork 10.118.69.100/test/debian-dind-1.13.1
docker inspect dind-test | grep IPAddress

# Now you can talk to the nested Docker endpoint
docker -H 10.118.69.89:2376 run hello-world
```

**Run with Port Mapping**

This is variation on the above example, except in this case, the Docker host does not get an identity on the public network

```docker run -d -p 10001:2376 <registry>/<imageid>```

Run a test container in new Docker host: 
```docker -H <vchipaddress>:10001 run --rm hello-world```

**Setting memory and CPU on the VM**

Add ```-m <mem> and --cpuset-cpus <vcpus>``` on the docker command-line to set resource constraints for the docker host

Example:

```
docker run -d --cpuset-cpus 4 -m 4g --net=ExternalNetwork 10.118.69.100/test/photon-dind-1.12
```

**Alternative to using docker -H**

For simplicity, you can set DOCKER_HOST=<ipaddress:port> instead of using -H on the docker command

**Passing options through to the Docker Daemon**

Note that in the Dockerfile, $DOCKER_OPTS is added as an environment variable. That means you can simply pass options to the Docker daemon via the command that starts the Docker host using the -e flag. This is particularly useful for things like setting an insecure registry to pull from.

Example:

```
docker run -e DOCKER_OPTS='--insecure-registry 10.118.69.100' -d --net=ExternalNetwork 10.118.69.100/test/photon-dind-1.12
docker -H 10.118.69.85:2376 pull 10.118.69.100/test/foobedoo
```
