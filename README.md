# Logstash Forwarder Agent

Logstash Forwarder is a Go implementation of Logstash Lumberjack forwarder.

The docker container will mount TLS keys from the host OS.

## Install

- `git clone git@github.com:ride-share-market/logstash-forwarder.git`
- `cd logstash-forwarder && git checkout develop`

## Create TLS keys.

These keys are stored in the repo secrets file, but this is how you'd initially create them.

1) On the Docker host machine

# certificates: /etc/pki/tls/certs/logstash-forwarder/
# keys: /etc/pki/tls/private/logstash-forwarder/

sudo mkdir -p /etc/pki/tls/certs/logstash-forwarder
sudo mkdir -p /etc/pki/tls/private/logstash-forwarder

2)
sudo openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout rsm-logstash-forwarder.key -out rsm-logstash-forwarder.crt -days 365 -subj /CN=logstash.ridesharemarket.com

sudo mv rsm-logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder/
sudo mv rsm-logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder/

3)

# Logstash Configuration (this is in the RSM logstash cookbook)

input {
  lumberjack {
    port => 9876
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder/rsm-logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder/rsm-logstash-forwarder.key"
    codec => "json"
  }
}

4)

## Deploy on local VM.

# TODO: clean up these notes.

sudo docker pull 192.168.33.10:5000/rudijs/rsm-logstash-forwarder:0.0.1

sudo docker run -i --rm --name rsm-logstash-forwarder --add-host vbox.ridesharemarket.com:192.168.33.10 -v /etc/pki/tls:/etc/pki/tls --volumes-from rsm-app -t 192.168.33.10:5000/rudijs/rsm-logstash-forwarder:0.0.1 /bin/bash

sudo docker run -d --name rsm-app-logstash-forwarder --add-host vbox.ridesharemarket.com:192.168.33.10 -v /etc/pki/tls:/etc/pki/tls --volumes-from rsm-app -t 192.168.33.10:5000/rudijs/rsm-logstash-forwarder:0.0.3

--config=/srv/ride-share-market-app/config/rsm-app-logstash-forwarder.json > /var/log/logstash-forwarder.log 2>&1

./logstash-forwarder --quiet=true --config=/srv/ride-share-market-app/config/rsm-app-logstash-forwarder.json > /var/log/logstash-forwarder.log 2>&1
