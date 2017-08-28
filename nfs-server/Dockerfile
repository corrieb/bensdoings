FROM debian

RUN apt-get update && apt-get install -yy vim procps kmod nfs-kernel-server

CMD [ "/etc/rc.local" ]

COPY rc.local /etc/
