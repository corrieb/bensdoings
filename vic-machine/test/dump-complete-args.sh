#!/bin/bash
mkdir vch
cp ../example-complete.json vch/config.json
../vic-machine 1.2.0 vch dumpargs
rm -fr vch
