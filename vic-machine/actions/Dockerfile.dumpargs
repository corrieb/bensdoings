FROM vic-machine-base:latest

COPY validate.sh parse.sh map-create.json /

WORKDIR /config

CMD /bin/sh -c "echo $(/validate.sh /config/config.json /map-create.json && /parse.sh /config/config.json /map-create.json)"
