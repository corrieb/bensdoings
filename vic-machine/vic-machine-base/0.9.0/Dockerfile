FROM debian:jessie

RUN apt-get update && apt-get install -y jq ca-certificates curl tar

RUN mkdir /vic \
    && curl -L https://bintray.com/vmware/vic/download_file?file_path=vic_0.9.0.tar.gz | tar xz -C /vic \
    && cp /vic/vic/vic-machine-linux /vic \
    && cp /vic/vic/*.iso /vic \
    && rm -fr /vic/vic

CMD ["/bin/bash"]
