FROM vic-machine-base:latest

COPY parse.sh map-thumbprint.json /

WORKDIR /config

CMD /bin/sh -c "/vic/vic-machine-linux inspect $(/parse.sh /config/config.json /map-thumbprint.json)" | grep thumbprint | cut -d "(" -f 2 | cut -d ")" -f 1
