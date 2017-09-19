FROM vic-machine-base:latest

COPY validate.sh parse.sh map-create.json /

WORKDIR /config

CMD /bin/sh -c "/validate.sh /config/config.json /map-create.json && /vic/vic-machine-linux create $(/parse.sh /config/config.json /map-create.json)"
