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

Let's start with a simple example. This assumes you've configured `DOCKER_HOST` to point to a VCH.

```
docker run -d --name nfs-server1 -p 111:111 -p 2049:2049 -p 32767:32767 -p 32768:32768 bensdoings/nfs-server
```
This uses all of the defaults described above and is using port-mapping to expose the NFS server on ports on the VCH endpoint IP. It runs the container as a daemon and you can see the output by running `docker logs nfs-server1`.

Let's now start an NFS client interactively in another container and see if we can successfully mount this share.

```
docker run -it bensdoings/nfs-server /bin/bash
$ modprobe nfs
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
Another great feature in VIC 1.2 is the ability to exec into a container interactively. We can now exec into our nfs-server container to see if the `hello` file we created is there:

```
docker exec -it nfs-server1 /bin/bash
$ ls /home/nfs
hello
$ exit
```





