# Purpose of this Dockerfile is to create a VIC image that runs nested Docker that can be accessed remotely
# You can use this image to build Docker images, general development, run tests etc.

# Build Dockerfile with regular Docker using: docker build -t <registry>/<imageid> .
# Push to a registry: docker login <registry>; docker push <registry>/<imageid>

# Run in VIC with external IP: docker run -d -net=<Public Network> <registry>/<imageid>
# Find IP address of the deployed VM: docker inspect <containerid> | grep IPAddress
# Run a test container in new Docker host: docker -H <ipaddress>:2376 run --rm hello-world

# Run in VIC with port mapping: docker run -d -p 10001:2376 10.118.69.100/test/photon-dind-1.12
# Run a test container in new Docker host: docker -H <vchipaddress>:1001 run --rm hello-world

# For simplicity, you can set DOCKER_HOST=<ipaddress:port> instead of using -H

FROM vmware/photon

RUN tdnf install -y iptables net-tools docker 1.12.6-1.ph1

CMD /usr/bin/dockerd -H tcp://0.0.0.0:2376
