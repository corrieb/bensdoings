FROM debian:jessie

RUN apt-get update && apt-get install -y jq ca-certificates curl tar

RUN mkdir /vic \
    && curl -L https://storage.googleapis.com/vic-engine-releases/vic_1.2.0.tar.gz | tar xz -C /vic \
    && cp /vic/vic/vic-machine-linux /vic \
    && cp /vic/vic/*.iso /vic \
    && rm -fr /vic/vic

CMD ["/bin/bash"]
