FROM vic-machine-base:latest

COPY validate.sh parse.sh map-firewall.json /

WORKDIR /config

CMD /bin/sh -c "/validate.sh /config/config.json /map-firewall.json && /vic/vic-machine-linux update firewall --deny $(/parse.sh /config/config.json /map-firewall.json)"
