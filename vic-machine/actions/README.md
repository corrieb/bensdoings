There is a Dockerfile for each vic-machine action. Not all actions are supported by all versions

Note that the CMD in the Dockerfiles use a nested /bin/sh. 
This is intentional and necessary for correct string parsing of the options (handling spaces in parameters for example)
