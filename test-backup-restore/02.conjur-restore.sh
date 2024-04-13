#!/bin/bash

node_name=conjur

set +x

data_file="$(ls -t /opt/cyberark/$node_name/backups/*.gpg | head -n1)"
key_file="/opt/cyberark/$node_name/backups/key"
data_file_name="$(basename $data_file)"

if [ ! -f $data_file ] || [ ! -f $key_file ]; then
    echo "Backup data is not existed. Please run backup command before doing restore!!!"
    exit
else
    echo "Backup data found. Starting restore process... "
    echo "Key file: $key_file"
    echo "Data file: $data_file"
    docker exec $node_name evoke unpack backup --key /opt/conjur/backup/key /opt/conjur/backup/$data_file_name
    docker exec $node_name evoke restore --accept-eula
fi
