#!/bin/bash

source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi


set +x

docker stop $node_name
docker container rm $(docker ps -a | grep $node_name | awk '{print $1}')

mkdir -p /opt/cyberark/conjur/{security,config,backups,seeds,logs}
chmod o+x /opt/cyberark/conjur/config

docker run \
    --name conjur \
    --detach \
    --restart=unless-stopped \
    --security-opt seccomp=unconfined \
    --publish "$POC_CONJUR_HTTPS_PORT:443" \
    --publish "444:444" \
    --publish "5432:5432" \
    --publish "1999:1999" \
    --log-driver journald \
    --volume /opt/cyberark/conjur/config:/etc/conjur/config:Z \
    --volume /opt/cyberark/conjur/security:/opt/cyberark/conjur/security:Z \
    --volume /opt/cyberark/conjur/backups:/opt/conjur/backup:Z \
    --volume /opt/cyberark/conjur/seeds:/opt/cyberark/conjur/seeds:Z \
    --volume /opt/cyberark/conjur/logs:/var/log/conjur:Z \
    registry.tld/conjur-appliance:$conjur_version

docker ps

set -x