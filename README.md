# bensdoings
Hacks around vSphere Integrated Containers

This repository is a place for various hacks and experimental work around vSphere Integrated Containers. Primarily it's a way to inspire others as to the flexibility and capabilities of VIC.

**DinD (aka Docker-in-Docker aka Docker-in-VIC)**

Do you need a regular Docker Host? Do you want to be able to treat Docker Hosts as ephemerally as Containers? Then this is what you need. Various Dockerfiles, instructions and scripts on how to spin up vanilla Docker hosts using VIC. This project underpins many of the other ones, such as the Docker Datacenter work.

**DDC**

Want to spin up Docker Datacenter into a VCH using Docker with some simple JSON config? These Dockerfiles and scripts take an existing VCH and stand up a Docker Datacenter cluster into it.

**vic-machine**

The vic-machine tool is what you use to install a VCH. The number of arguments it takes and the need to repeat subsets of those args for various tasks can be painful. This hack presents a super simple way to stand up VCHs using Docker and some simple JSON.

**vic-build**

Want to build VIC? VIC is actually a great way to do it. It's the way I do it.

