#!/bin/bash

node_name=conjur

set +x

data_file="$(ls -t /opt/cyberark/conjur/backups/*.gpg | head -n1)"
key_file="/opt/cyberark/conjur/backups/key"

if [ ! -f $data_file ] || [ ! -f $key_file ]; then
    echo "Backup data is not existed. Please run backup command before doing restore!!!"
    exit
else
    echo "Backup data found. Starting restore process... "
    echo "Key file: $key_file"
    echo "Data file: $data_file"
    docker exec $node_name evoke unpack backup --key $key_file $data_file
    docker exec $node_name evoke restore --accept-eula
fi


set -x