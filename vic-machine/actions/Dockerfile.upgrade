FROM vic-machine-base:latest

COPY validate.sh parse.sh map-upgrade.json /

WORKDIR /config

CMD /bin/sh -c "/validate.sh /config/config.json /map-upgrade.json && /vic/vic-machine-linux upgrade $(/parse.sh /config/config.json /map-upgrade.json)"
