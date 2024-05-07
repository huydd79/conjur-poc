#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

source ./00.config.sh

if [ ! -f "data/jwt.pub" ]; then
    echo "Please run jwt docker to generate jwks file before running this script"
    exit
fi

CONJUR_URL="https://$CONJUR_IP:$POC_CONJUR_HTTPS_PORT"
PUB_CRT_FILE="data/jwt.pub"

# Loading conjur policy for jwt authentication
echo "Configuring authn-jwt/$JWT_SERVICE_ID authenticator... "
cp policies/policy-jwt-auth.yaml data/policy-jwt-auth.yaml
sed -i "s/\$JWT_SERVICE_ID/$JWT_SERVICE_ID/g" data/policy-jwt-auth.yaml
conjur policy load -b root -f data/policy-jwt-auth.yaml
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

# Loading conjur policy for host id and its permission
echo "Loading policy for $JWT_HOST_ID and its permission... "
cp policies/policy-app-access.yaml data/policy-app-access.yaml
sed -i "s/\$JWT_SERVICE_ID/$JWT_SERVICE_ID/g" data/policy-app-access.yaml
sed -i "s/\$JWT_HOST_ID/$JWT_HOST_ID/g" data/policy-app-access.yaml
conjur policy load -b root -f data/policy-app-access.yaml
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

# Loading jwt authentication data
echo "Loading jwt authentication data... "
pub_keys='{"type":"jwks", "value": {"keys":['$(cat $PUB_CRT_FILE)']}}'
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/public-keys -v "$pub_keys"
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/token-app-property -v host
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/identity-path -v jwt-apps/$JWT_SERVICE_ID
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/issuer -v $JWT_SERVICE_ISS

# Generating /etc/conjur/config/conjur.yaml file
echo "Generating conjur configuration for authenticators options... "
CONF_FILE=/opt/cyberark/conjur/config/conjur.yml
[ -f "$CONF_FILE" ] && mv $CONF_FILE $CONF_FILE.bk.$(date +%s)
#Enabling all configured authn methods
auth_json=$(curl -sk $CONJUR_URL/info | jq '.authenticators.configured')
cat << EOF > $CONF_FILE
#This file is created by script: 02.configuring_jwt_script.sh" 
authenticators: $auth_json
EOF

echo "Activating authn-jwt/$JWT_SERVICE_ID authenticator..."
$SUDO $CONTAINER_MGR exec conjur evoke configuration apply
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

echo "Double check for the authenticator configuration:"
curl -sk $CONJUR_URL/info | jq '.authenticators'
