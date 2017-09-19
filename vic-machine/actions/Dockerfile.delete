FROM vic-machine-base:latest

COPY validate.sh parse.sh map-delete.json /

WORKDIR /config

CMD /bin/sh -c "/validate.sh /config/config.json /map-delete.json && /vic/vic-machine-linux delete $(/parse.sh /config/config.json /map-delete.json)"
