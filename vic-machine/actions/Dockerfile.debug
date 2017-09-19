FROM vic-machine-base:latest

COPY validate.sh parse.sh map-debug.json /

WORKDIR /config

CMD /bin/sh -c "/validate.sh /config/config.json /map-debug.json && /vic/vic-machine-linux debug $(/parse.sh /config/config.json /map-debug.json)"
