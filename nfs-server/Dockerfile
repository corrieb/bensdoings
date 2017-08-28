FROM debian

RUN apt-get update && \
    apt-get install -yy procps kmod nfs-kernel-server && \
    mkdir /run/sendsigs.omit.d

CMD [ "/etc/rc.local" ]

COPY rc.local /etc/
