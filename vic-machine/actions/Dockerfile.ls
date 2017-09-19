FROM vic-machine-base:latest

COPY validate.sh parse.sh map-ls.json /

WORKDIR /config

CMD /bin/sh -c "/validate.sh /config/config.json /map-ls.json && /vic/vic-machine-linux ls $(/parse.sh /config/config.json /map-ls.json)"
