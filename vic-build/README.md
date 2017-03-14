**Building VIC with VIC**

So why would you want to build VIC with VIC and how can we optimize the process? That's what we'll expore here.

***Overview***

VIC is like many open-source projects in that to build it, you pull from GitHub, make sure you have the right dependencies installed and then run ``make``

Sounds simple. But there are a few questions we need to figure out:

1. What machine am I going to build on and how stateful do I want it to be?
2. How easy should it be to update my build environment?
3. Where do I want my build output to be persisted and can I persist it independent of the environment?
4. How can I optimize my builds?

As you'll see from https://github.com/vmware/vic, you're presented with 3 options:

1. Run the Vagrant scripts in https://github.com/vmware/vic/tree/master/infra/machines/devbox and create a long-running VM that will become stateful over time.
2. Run the build in your Docker environment using the golang:1.8 image by mounting a local volume into the container. 
3. Go your own way. You'll have to install all your own dependencies and maintain this new pet you created

So what's good and bad about these options. Well, all of them presume a long-running stateful VM exists. (1) Automates the process of getting one. (2) Attempts to make your VM less stateful, but still leaves a bunch of crud in your Docker image cache. (3) Understandable if you have a Linux template you must use, but you almost certainly want to automate its creation somehow.

Let's evaluate these in terms of the questions we asked above:

1. Each one of these is a stateful pet. All of them tie your local build tree to the lifecycle of the VM, unless you use an NFS mount or equivalent.
2. Updating...
 - (1) is probably best done by deleting it and recreating. 
 - (2) Is much simpler because dependencies are much more transient, but the downside to that is that any dependencies downloaded within the process of the docker container need to be repeated each time (unless you create a custom image). 
 - With (3), either use Chef or try to recreate. Impact of deleting and recreating the VM is significant if you have local state you don't want to lose.
3. As we've discussed, persisting local build state independent of the lifecycle of the build environment is not at all easy with any of these options without a networked filesystem.
4. There are a few ways we can optimze here. 
 - We can cache build dependencies so that they're not downloaded each time, while also making it easy to update them when we need to. 
 - We can make sure that we only burn compute resources to run builds when we need them. 
 - It would also be nice to be able to choose how much compute resources to dedicate to a particular build.

In summary, the optimizations we aspire to here are not all possible with a stateful build environment. If you have a large bare-metal Docker environment, then (2) is probably the cleanest option, provided you garbage collect that image cache!

**So what can we do with VIC?**

VIC allows us to have all the optimizations we're looking for because we can spin up ephemeral compute resource to run builds and keep our source tree on a volume on a vSphere datastore that persists completely independent of a VM.





