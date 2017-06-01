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

**Modifying**

You'll see that the JSON keys map to vic-machine arguments in ``actions/map-x.json``. If you wish, you can define your own JSON schema by simply modifying those files.

**Calling vic-machine directly**

If you want, you can use the script to generate args and then use those args to invoke vic-machine directly. This is particularly useful for debugging, understanding how the JSON maps to the args or seeing the help output of vic-machine.

```
> docker run bensdoings/vic-machine-direct:1.1.1
Use this image to run vic-machine directly: docker run <image> vic-machine-linux <cmd> <args>

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

**Building Your Own Images From The VIC OVA**

Coming soon!
