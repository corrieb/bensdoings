FROM golang:1.8

VOLUME /go/src/github.com/vmware

RUN mkdir -p /go/src/github.com/vmware \
    && cd /go/src/github.com/vmware \
    && git clone https://github.com/vmware/vic.git \
    && cd vic \
    && make all 

WORKDIR /go/src/github.com/vmware/vic

CMD make all
