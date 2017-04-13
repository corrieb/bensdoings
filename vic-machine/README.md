The purpose of this hack is to vastly simplify the operation of the vic-machine binary and to make vic-machine available from Docker Hub.

vic-machine today takes a large number of arguments and each command takes a different subset of arguments. As such, your instinct will be to script it, but you'll quickly find that you end up with a massive proliferation of scripts, particularly if you have multiple VCHs.

This hack proposes a simple JSON manifest for a VCH setup. It contains, VC connection information, VCH configuration etc. organized in a hierarchical way that makes the overall configuration much easier to parse by eye and modify. This JSON manifest is then used as input to all vic-machine commands, which are themselves invoked using docker. All of this can then be invoked from a super simple single script.

Here's how to get started:

**Usage**

Use the example.json in the repository as a starting point, edit it and place it in a subdirectory with a memorable name. Name it config.json. Note you can find the correct thumprint by running create without a thumbprint.

Now copy ./vic-machine.sh into the root of your local folder. You should now see:

```
> ls -l
vic-machine.sh
MyVCH/config.json
```
Now simply run ``./vic-machine.sh`` to see how to use it. 

To create a VCH with the latest version of VIC, you simply run ``./vic-machine.sh latest MyVCH create``

Note that any generated certificates will be placed in the subdirectory you selected under another subdirectory of the same name

**Modifying**

You'll see that the JSON keys map to vic-machine arguments in ``actions/map-x.json``. You can define your own JSON schema by simply modifying those files.
