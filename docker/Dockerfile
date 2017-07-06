FROM ubuntu:14.04
MAINTAINER Chen Yang <yangchen08@tamu.edu>
LABEL Description="This image is used to run an ibrdtn daemon from Ubuntu 14.04 package"

RUN apt-get update && apt-get install -y \
      git build-essential libssl-dev libz-dev libsqlite3-dev \
      libcurl4-gnutls-dev libdaemon-dev automake autoconf pkg-config libtool libcppunit-dev \
      libnl-3-dev libnl-cli-3-dev libnl-genl-3-dev libnl-nf-3-dev libnl-route-3-dev libarchive-dev \
      libarchive-dev net-tools vim \
  --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /ibrdtn/
COPY ibrdtnd.conf /ibrdtnd.conf
COPY *.tar.gz /ibrdtn/
RUN cd /ibrdtn && tar xzf ibrcommon-1.0.1.tar.gz && tar xzf ibrdtn-1.0.1.tar.gz \ 
  && tar xzf ibrdtnd-1.0.1.tar.gz && tar xzf ibrdtn-tools-1.0.1.tar.gz
RUN cd /ibrdtn/ibrcommon-1.0.1 && ./configure && make -j4 && make install
RUN cd /ibrdtn/ibrdtn-1.0.1 && ./configure && make -j4 && make install
RUN cd /ibrdtn/ibrdtnd-1.0.1 && ./configure && make -j4 && make install
RUN cd /ibrdtn/ibrdtn-tools-1.0.1 && ./configure && make -j4 && make install

RUN echo "include /usr/local/lib/*" >> /etc/ld.so.conf && ldconfig

EXPOSE 4556 4551 4550 

ENTRYPOINT ["/bin/bash"]