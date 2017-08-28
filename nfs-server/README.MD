**VIC NFS File Server Container**

This is a Dockerfile for a container that runs a simple NFS server in VIC.

Shared read-write storage absolutely has its place. Binary dependencies, a shared place to write logs etc. This NFS server gives you the ability to expose either a VIC volume or some ephemeral scratch space to multiple NFS clients, which could potentially be other containers. 

Explicitly mounting NFS shares into a client container is ugly though. It requires that the container have the dependencies baked into it and the NFS client services running, which is a leaky abstraction. This is an infrastructure concern and this is what the Volume abstraction is for.

So In VIC 1.2, we have built-in support for NFS volumes, so an NFS mount can be registered as a volume store and containers can sub-allocate shared read-write storage from it. That solves the problem of the client container needing to have any awareness of NFS. 

When you combine that with the ability in VIC 1.2 to reconfigure a Virtual Container Host, I'm going to show you how you can use the NFS server to expose any VMDK as read-write storage to any container in a VCH completely transparently. That's cool!

*An example of Kernel Modules in a container VM*

Note that there are already some NFS server containers in DockerHub, but all of them are designed to expose a piece of the filesystem of the host the container runs on. They will also require that the appropriate kernel modules are loaded and configured in the host.

VIC is different in that a container VM gets its own kernel and can load its own kernel modules without impacting any other container. It also treats persistent Volumes as first-class entities, completely independent of any VM or even ESXi host.

So you'll notice that `kmod` is loaded in the Dockerfile and the script that starts the nfs server loads the kernel module. This level of kernel isolation, combined with peristent storage that's completely independent of any host is a great example of VIC container security in action.

**Building the container**

Build the container with regular Docker, just as you would any other container. I've built one to DockerHub at `bensdoings/nfs-server:latest` which you'll see used in the examples below.

```
docker build -t <registry-name>/<project-name>/nfs-server:<version> .
docker login <registry-name>
docker push <registry-name>/<project-name>/nfs-server:<version>
```

*A few notes on the design of the Dockerfile and script*

Given that multiple services need to be run, I've used the same approach I used in the dind scripts of having a separate `rc.local` that does the work and handles graceful container stop. The main container process is simply a sleep that's been renamed so that it's unambiuously identifiable when we need to find its pid and kill it. 

I've made the server configurable so that the directory to be exported, the ports to be used and the export options can all be specified, but with sensible defaults. The server is designed to only have one export. It would be simple to modify it for multiple.

**Running the container**

The NFS server needs 4 ports exposed. The defaults are: `111`, `2049`, `32767` and `32768`. The latter are needed by `lockd` and `mountd` and are configurable as `LOCKD_PORT` and `MOUNTD_PORT` environment variables. They need to be hard-coded so that appropriate ports can be exposed in the `docker run` command.

The container also needs to know which directory you want to export. By default, it creates and exports `/home/nfs` which will be ephemeral scratch space unless a persistent volume is mounted to that location. This is also configurable as `EXPORT_FOLDER`.

Lastly the export configuration by default is `*(rw,no_root_squash,no_subtree_check)`, which is configurable as `EXPORT_OPTS`.

As you'll see from the rc.local file, all of the late binding of configuration is done with the environment variables above.

*Simple example*

Let's start with a simple example. This assumes you've configured `DOCKER_HOST` to point to a VCH.

```
docker run -d --name nfs-server1 -p 111:111 -p 2049:2049 -p 32767:32767 -p 32768:32768 bensdoings/nfs-server
```
This uses all of the defaults described above and is using port-mapping to expose the NFS server on ports on the VCH endpoint IP. It runs the container as a daemon and you can see the output by running `docker logs nfs-server1`. Note that this configuration exports a part of the container filesystem, which is ephemeral storage. See below for exporting persistent storage.

*Testing with an NFS client*

Let's now start an NFS client interactively in another container and see if we can successfully mount this share. We can use the same nfs-server image as it has all the necessary dependencies.

```
docker run -it bensdoings/nfs-server /bin/bash
$ service rpcbind start
$ service nfs-common start
$ mkdir /mnt/nfs-share
$ echo '<vch-address>:/home/nfs /mnt/nfs-share   nfs  defaults,noauto,user 0 0' > /etc/fstab
$ mount /mnt/nfs-share
$ touch /mnt/nfs-share/hello
$ ls /mnt/nfs-share
hello
$ exit
```
*Verifying on the server*

Another great feature in VIC 1.2 is the ability to exec into a container interactively. We can now exec into our nfs-server container to see if the `hello` file we created is there:

```
docker exec -it nfs-server1 /bin/bash
$ ls /home/nfs
hello
$ exit
```
**Exporting Persistent Storage**

Exporting a persistent volume as an NFS share is a simple matter of mounting the volume into the NFS server container and configuring it appropriately. This ensures that the state is persisted beyond the lifecycle of the nfs-server container or even the VCH that created the volume.

```
docker volume create --name nfs-vol --opt Capacity=5G
docker run -d -v nfs-vol:/home/nfs --name nfs-server1 -p 111:111 -p 2049:2049 -p 32767:32767 -p 32768:32768 bensdoings/nfs-server
```

If you wanted to use a non-default location for the export, you would configure it like this:
```
docker run -d -v nfs-vol:/mnt/nfs-vol --name nfs-server1 -p 111:111 -p 2049:2049 -p 32767:32767 -p 32768:32768 -e EXPORT_FOLDER=/mnt/nfs-vol bensdoings/nfs-server
```
You then need to remember the mount point you chose because it will be used when configuring the client.

**Network Configurations**

Using port mapping as shown above may be a simple way to run a test, but is not appropriate for production. Firstly, it places the VCH endpoint VM in the data path, which is problematic in the scenario where the VCH needs to be reconfigured or upgraded. Secondly it's inefficient as it uses NAT. Much better to have the NFS server exposed directly on vSphere Port Group.

*Container Network*

The most straightforward way to achieve this - and one which is necessary if the nfs-server is to be addressable outside of the context of the VCH - is to use a container network (`--container-network` on vic-machine). This allows you to attach containers directly to a vSphere port group and the container gets a unique network identity on that port group.

Here's the same example as above, but instead using a container network. Note that in VIC 1.2, we've introduced a firewall capability to a container network and so by default, you need to specify the ports you want open on the firewall. If you're using VIC 1.1.1, you should therefore eliminate the -p arguments.

```
docker volume create --name nfs-vol --opt Capacity=5G
docker run -d -v nfs-vol:/mnt/nfs-vol --net ExternalNetwork --name nfs-server1 -p 111 -p 2049 -p 32767 -p 32768 -e EXPORT_FOLDER=/mnt/nfs-vol bensdoings/nfs-server
docker inspect nfs-server1 | grep IPAddress 
```

Go ahead and power down the VCH endpoint VM if you want to test the isolation here. With the endpoint VM powered down, you won't be able to exec into the nfs-server, but the client-server communications continue to function.

*Changing Ports*

If you want to specify the ports for lockd and mountd, these can be specified as follows:

```
docker run -d -v nfs-vol:/mnt/nfs-vol --net ExternalNetwork --name nfs-server1 -p 111 -p 2049 -p 4001 -p 4002 -e EXPORT_FOLDER=/mnt/nfs-vol -e MOUNTD_PORT=4001 -e LOCKD_PORT=4002 bensdoings/nfs-server
```
The other two ports are currently fixed as these are standard NFS ports. On a container-network, there are no issues with port conflicts since every container gets its own network identity.

**Creating a Volume Store from an NFS share (VIC 1.2+ only)**

New in VIC 1.2 is the ability to create a container volume store from an NFS share. This adds the capability for containers to mount shared read/write storage completely transparently. Use-cases are:

 - Seeding containers with shared read-only dependencies, such as builds or tools
 - Allowing multiple containers to mount the same volume read-write. This is particularly useful in a cloud scenario where logs or output can be created in the same location from any number of containers.
 
Given that we can now use VIC to create an NFS share and given that it's now possible to re-configure a VCH to add a Volume store, we can expose a VIC volume as read-write shared storage to any number of containers within the VCH. Here's how it's done.

Let's start using the container-network example from above. Once the nfs server is running, we need to reconfigure the VCH to add that NFS share as a volume store. In order to do this, all of the `--volume-store` arguments need to be specified, including ones previously configured. 

Here's the vic-machine options I used when installing the VCH into a vSphere cluster:
```
vic-machine create --bridge-network dev-cert --compute-resource Minis --debug 1 --image-store iSCSI-nvme --name dev-cert --password xxxxxxx --public-network ExternalNetwork --target bcorrie-test6.eng.vmware.com/Datacenter --thumbprint xxxxxxx --timeout 500s --tls-cname *.eng.vmware.com --user administrator@vsphere.local --volume-store iSCSI-nvme/volumes/minis-dev-cert:default --container-network ExternalNetwork
```

Once I've created the NFS share above, I'm going to make the following subsequent call to vic-machine:
```
vic-machine-linux configure --target bcorrie-test6.eng.vmware.com/Datacenter --thumbprint xxxxxxx --timeout 500s --user administrator@vsphere.local --password xxxxxxx --volume-store 'nfs://10.118.68.238/mnt/nfs-vol?uid=0&gid=0&proto=tcp:nfs-store' --compute-resource Minis --name dev-cert --volume-store iSCSI-nvme/volumes/minis-dev-cert:default
```
This will reconfigure the VCH to add the NFS share as a datastore. As I mentioned above, you need to specify the original datastores in addition to the new one. Note also the user and group ids specified. That's important to specify so that it's consistent with what's in the NFS server. 

The reconfiguration will cause a power-cycle of the VCH endpoint VM, the same as an upgrade. Once the power-cycle has completed, type `docker info` and if everything worked correctly, you should see a volume store called `nfs-store` in addition to one called `default`. If the volume store doesn't show up, it's likely that something was misconfigured. The best place to look for a reason why is the Port Layer logs in the vic-admin portal, which is at `<vch-address>:2378`. If you do have a mis-configured volume store, you can't currently remove or modify it, but you can add another one with the correct configuration using the same approach. 

Once the volume store is added, let's test it.

```
docker volume create --name nfs-vol-1 --opt VolumeStore=nfs-store
docker run -v nfs-vol-1:/data -it debian
$ touch /data/from-c1
$ ls /data
from-c1
```
Then in another terminal, start another container in the same VCH using the same volume:

```
docker run -v nfs-vol-1:/data -it debian
$ touch /data/from-c2
$ ls /data
from-c1 from-c2
```
