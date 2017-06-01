#!/bin/bash
mkdir vch
cp ../example-complete.json vch/config.json
../vic-machine 1.1.1 vch dumpargs
rm -fr vch
