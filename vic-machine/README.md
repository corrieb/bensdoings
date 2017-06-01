The purpose of this hack is to vastly simplify the operation of the vic-machine binary and to make vic-machine available from Docker Hub.

vic-machine today takes a large number of arguments and each command takes a different subset of arguments. As such, your instinct will be to script it, but you'll quickly find that you end up with a massive proliferation of scripts, particularly if you have multiple VCHs.

This hack proposes a simple JSON manifest for a VCH setup. It contains, VC connection information, VCH configuration etc. organized in a hierarchical way that makes the overall configuration much easier to parse by eye and modify. This JSON manifest is then used as input to all vic-machine commands, which are themselves invoked using docker. All of this can then be invoked from a single script.

Here's how to get started:

**Usage**

Use the example json files in the repository as a starting point, edit it and place it in a subdirectory with a memorable name. Name it config.json. (Note you can find the correct thumprint by running ``vic-machine-thumbprint`` without a thumbprint)

Now copy ./vic-machine into the root of your local folder. You should now see:

```
> ls -l
vic-machine
MyVCH/config.json
```
Now simply run ``./vic-machine`` to see how to use it. 

To create a VCH with the latest version of VIC, you simply run ``./vic-machine latest MyVCH create``

Note that any generated certificates will be placed in the subdirectory you selected under another subdirectory of the same name

**Building Your Own Images From The VIC OVA**

Once you've successfully installed the VIC OVA, if you want to use this capability, the most obvious thing is to build and push vic-machine to your registry. You can then run vic-machine anywhere that can see your registry. There are some very small modifications to the scripts to show you how to do this.

*Step 1: Build the images*

In order to build the images, you need a recent version of docker installed locally. 
- Once you have that, modify the Dockerfile in vic-machine/vic-machine-base/OVA to point to your registry IP and the correct tar file name
  - To see the tar file name to specify, you can use ``wget -qO- --no-check-certificate https://<ipaddress>:9443``
- Once that's correct, edit vic-machine/build/build.sh and change the following:
  - Set BUILD_FROM_OVA=true 
  - Set REPO_NAME to your desired registry IP and project name. You'll see an example provided
- You can now run build.sh

*Step 2: Push the images*

In order to push the images, you need a project set up with a user that you will then need to authenticate as:
- Navigate to the VIC registry
- Create a new Project
- Add yourself as a user with push permissions
- From your docker client, type ``docker login <ipaddress>`` and authenticate with the registry
  - Note that if this is your first time authenticating, you'll need to add ca.crt to ``/etc/docker/certs.d/<ipaddress>/`` and restart the docker daemon
  - You download ca.crt from VIC registry by selecting "admin" in the top right and "Download Root Cert"
- Edit the vic-machine/build/push.sh script and set the REPO_NAME to point to the same one you used in the build script
- You can now run push.sh

**Modifying**

You'll see that the JSON keys map to vic-machine arguments in ``actions/map-x.json``. If you wish, you can define your own JSON schema by simply modifying those files.

**Calling vic-machine directly**

If you want, you can use the script to generate args and then use those args to invoke vic-machine directly. This is particularly useful for debugging, understanding how the JSON maps to the args or seeing the help output of vic-machine.

```
> docker run bensdoings/vic-machine-direct:1.1.1
Use this image to run vic-machine directly: docker run <image> -v <certs-dir>:/certs vic-machine-linux <cmd> <args>

> docker run bensdoings/vic-machine-direct:1.1.1 vic-machine-linux create --help
NAME:
   vic-machine-linux create - Deploy VCH
...

# dumpargs dumps the arguments for the create action. Arguments to other actions are a subset of these
# note that the path to any certificates will need to be changed to /cert due to the expected volume mount in vic-machine-direct

> ./vic-machine 1.1.1 MyVCH dumpargs > args.txt

> docker run -v $(pwd)/MyVCH:/certs bensdoings/vic-machine-direct:1.1.1 vic-machine-linux create $(cat args.txt | tr "\r" " ")
Jun  1 2017 16:38:15.154Z INFO  ### Installing VCH ####
...
```

