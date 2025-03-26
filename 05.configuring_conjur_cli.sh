#!/bin/bash

source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
#sudo dpkg -i $UPLOAD_DIR/conjur-cli-go_8.0.9_amd64.deb
rpm -Uvh $UPLOAD_DIR/conjur-cli-go_8.0.16_386.rpm

echo "$CONJUR_IP conjur.$POC_DOMAIN" >> /etc/hosts

conjur init -u https://conjur.$POC_DOMAIN:$POC_CONJUR_HTTPS_PORT --self-signed
conjur login -i admin
set +x
conjur whoami

