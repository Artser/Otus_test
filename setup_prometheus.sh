#!/bin/bash

sudo apt install prometheus

# ps afx
# ss -ntlp
# /etc/prometheus/prometheus.yml : в scrape_configs 
# (jobe_name: node, где порт 9100) нужно прописать в список
# наши системы с портами экспортеров.

sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_11.5.1_amd64.deb
sudo dpkg -i grafana_11.5.1_amd64.deb

## Adding system user `grafana' (UID 115) ...
#Adding new user `grafana' (UID 115) with group `grafana' ...
#Not creating home directory `/usr/share/grafana'.
#### NOT starting on installation, please execute the following statements to 
# configure grafana to start automatically using systemd
# sudo /bin/systemctl daemon-reload
# sudo /bin/systemctl enable grafana-server
#### You can start grafana-server by executing
# sudo /bin/systemctl start grafana-server
#

sudo systemctl daemon-reload
sudo systemctl start grafana-server

# sudo apt install prometheus-node-exporter
