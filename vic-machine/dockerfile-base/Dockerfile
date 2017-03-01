FROM debian:jessie

RUN apt-get update && apt-get install -y jq ca-certificates curl tar

RUN curl -L https://bintray.com/vmware/vic/download_file?file_path=vic_0.8.0.tar.gz | tar xz \
    && cp vic/vic-machine-linux /bin \
    && cp vic/*.iso \
    && rm -fr vic

CMD ["/bin/bash"]
