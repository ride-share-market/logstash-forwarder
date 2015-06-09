FROM ubuntu:14.04
MAINTAINER Ride Share Market "systemsadmin@ridesharemarket.com"

# APT cache
ENV APT_REFRESHED_AT 2015-06-09.1
RUN apt-get -yqq update

WORKDIR /root

# install deps
RUN \
    apt-get install -y git golang && \
    git clone git://github.com/elasticsearch/logstash-forwarder.git && \
    cd logstash-forwarder && \
    go build -o logstash-forwarder && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./logstash-forwarder/logstash-forwarder"]
