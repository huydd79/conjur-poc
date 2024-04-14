#!/bin/bash

CONJUR_URL="https://conjur.home.huydo.net"
CONF_FILE=/opt/cyberark/conjur/config/conjur.yml
SUDO=
CONTAINER_MGR=docker
JWT_SERVICE_ID=github


[ -f "$CONF_FILE" ] && mv $CONF_FILE $CONF_FILE.bk.$(date +%s)
auth_json=$(curl -sk $CONJUR_URL/info | jq '.authenticators.configured')
cat << EOF > $CONF_FILE
#This file is created by script $0
authenticators: $auth_json
EOF

echo "Activating authn-jwt/$JWT_SERVICE_ID authenticator..."
$SUDO $CONTAINER_MGR exec conjur evoke configuration apply
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

echo "Double check for the authenticator configuration:"
curl -sk $CONJUR_URL/info | jq '.authenticators'