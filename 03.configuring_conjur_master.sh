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
$SUDO $CONTAINER_MGR exec $masterContainer evoke configure $serverType \
    --accept-eula -h $masterDNS \
    --master-altnames "$clusterDNS,$standby1DNS" \
    -p $adminPass $accountName
set +x
