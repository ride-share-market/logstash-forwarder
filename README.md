1)

# certificates: /etc/pki/tls/certs/logstash-forwarder/
# keys: /etc/pki/tls/private/logstash-forwarder/

sudo mkdir -p /etc/pki/tls/certs/logstash-forwarder
sudo mkdir -p /etc/pki/tls/private/logstash-forwarder

2)
sudo openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout rsm-logstash-forwarder.key -out rsm-logstash-forwarder.crt -days 365 -subj /CN=logstash.ridesharemarket.com

sudo mv rsm-logstash-forwarder.crt /etc/pki/tls/certs/logstash-forwarder/
sudo mv rsm-logstash-forwarder.key /etc/pki/tls/private/logstash-forwarder/

3)

# Logstash

input {
  lumberjack {
    port => 9876
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder/rsm-logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder/rsm-logstash-forwarder.key"
    codec => "json"
  }
}

4)

# Logstash-Forwarder

git clone git://github.com/elasticsearch/logstash-forwarder.git
cd logstash-forwarder
go build -o logstash-forwarder


## Deploy

sudo docker pull 192.168.33.10:5000/rudijs/rsm-logstash-forwarder:0.0.1

sudo docker run -i --rm --name rsm-logstash-forwarder --add-host vbox.ridesharemarket.com:192.168.33.10 -v /etc/pki/tls:/etc/pki/tls --volumes-from rsm-app -t 192.168.33.10:5000/rudijs/rsm-logstash-forwarder:0.0.1 /bin/bash

sudo docker run -d --name rsm-app-logstash-forwarder --add-host vbox.ridesharemarket.com:192.168.33.10 -v /etc/pki/tls:/etc/pki/tls --volumes-from rsm-app -t 192.168.33.10:5000/rudijs/rsm-logstash-forwarder:0.0.3

--config=/srv/ride-share-market-app/config/rsm-app-logstash-forwarder.json > /var/log/logstash-forwarder.log 2>&1

./logstash-forwarder --quiet=true --config=/srv/ride-share-market-app/config/rsm-app-logstash-forwarder.json > /var/log/logstash-forwarder.log 2>&1
