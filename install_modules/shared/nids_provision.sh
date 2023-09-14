#!/bin/bash

PROJECT_ROOT_DIR=$1
AGENT_TYPE=$2
IP_HOST=$3

if [[ $AGENT_TYPE == 'heavy' ]]; then
	echo "Setting up Suricata conf..."
	cp $PROJECT_ROOT_DIR/build/shared/suricata/suricata.yaml /var/impulse/etc/suricata 
	cp $PROJECT_ROOT_DIR/build/shared/suricata/disable.conf /var/impulse/etc/suricata
	cp $PROJECT_ROOT_DIR/build/shared/suricata/drop.conf /var/impulse/etc/suricata
	cp $PROJECT_ROOT_DIR/build/shared/suricata/enable.conf /var/impulse/etc/suricata
	cp $PROJECT_ROOT_DIR/build/shared/suricata/capture-filter.bpf /var/impulse/etc/suricata

	cp $PROJECT_ROOT_DIR/build/shared/suricata/custom.rules /var/impulse/lib/suricata/rules
	cp $PROJECT_ROOT_DIR/build/shared/suricata/suricata.rules /var/impulse/lib/suricata/rules

	sed -i '/define_home_net/c\    HOME_NET: "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,'$IP_HOST']" # define_home_net' /var/impulse/etc/suricata/suricata.yaml
fi