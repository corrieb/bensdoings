FROM vic-machine-base:latest

COPY validate.sh parse.sh map-inspect.json /

WORKDIR /config

CMD /bin/sh -c "/validate.sh /config/config.json /map-inspect.json && /vic/vic-machine-linux inspect $(/parse.sh /config/config.json /map-inspect.json)"
