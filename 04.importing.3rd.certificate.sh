#!/bin/bash

source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
masterContainer=$node_name
serverType="master"
masterDNS="conjur-master.$POC_DOMAIN"
clusterDNS="conjur-master.$POC_DOMAIN"
standby1DNS="$node_name.$POC_DOMAIN"
adminPass=$POC_CONJUR_ADMIN_PW
accountName=$POC_CONJUR_ACCOUNT

$SUDO $CONTAINER_MGR exec $masterContainer evoke ca import \
	--no-restart \
	--root /opt/cyberark/conjur/certs/ca.crt

$SUDO $CONTAINER_MGR exec $masterContainer evoke ca import \
	--no-restart \
	--key /opt/cyberark/conjur/certs/conjur.key \
	--set /opt/cyberark/conjur/certs/conjur.crt 

$SUDO $CONTAINER_MGR exec $masterContainer sv restart conjur nginx pg seed

#Adding root ca to host's trusted authorities (this is applied for RHEL only)
cp /opt/conjur-poc/certs/ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

set +x
