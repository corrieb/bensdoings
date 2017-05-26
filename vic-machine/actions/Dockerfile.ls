FROM vic-machine-base:latest

COPY parse.sh map-ls.json /

WORKDIR /config

CMD /bin/sh -c "/vic/vic-machine-linux ls $(/parse.sh /config/config.json /map-ls.json)"
