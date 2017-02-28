Purpose of these Dockerfiles is to create VIC images that run nested Docker that can be accessed remotely. 

**Usage**

You can use these images to build Docker images, general development, run tests etc.

**Build**

Build Dockerfile with regular Docker using: 
```docker build -t <registry>/<imageid> .```

Push to a registry: 
```docker login <registry>; docker push <registry>/<imageid>```

*Note: Docker commands for running the container need to target a VIC endpoint. Use ```DOCKER_HOST=<vch-ip:port>``` or ```docker -H <vch-ip:port>```*

**Run with Public IP**

```docker run -d -net=<public-network> <registry>/<imageid>```

Find IP address of the deployed VM: ```docker inspect <containerid> | grep IPAddress```

Run a test container in new Docker host: ```docker -H <ipaddress>:2376 run --rm hello-world```

**Run with Port Mapping**

```docker run -d -p 10001:2376 <registry>/<imageid>``

Run a test container in new Docker host: 
```docker -H <vchipaddress>:1001 run --rm hello-world```

**Setting memory and CPU on the VM**

Add ```-m <mem> and -c <vcpus>``` on the docker command-line to set VM resource constraints

**Alternative to using docker -H**

For simplicity, you can set DOCKER_HOST=<ipaddress:port> instead of using -H

