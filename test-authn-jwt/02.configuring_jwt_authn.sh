#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

source ./00.config.sh

if [ ! -f "$PUB_CRT_FILE.jwks" ]; then
    echo "Please generate jwks file before running this script"
    exit
fi

CONJUR_URL="https://conjur.$POC_DOMAIN:$POC_CONJUR_HTTPS_PORT"
# Loading conjur policy for host id and its permission
echo "Loading policy for $JWT_HOST_ID and its permission... "
cp policies/policy-app-access.yaml data/policy-app-access.yaml
sed -i "s/\$JWT_SERVICE_ID/$JWT_SERVICE_ID/g" data/policy-app-access.yaml
sed -i "s/\$JWT_HOST_ID/$JWT_HOST_ID/g" data/policy-app-access.yaml
conjur policy load -b root -f data/policy-app-access.yaml
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"


# Loading conjur policy for jwt authentication
echo "Configuring authn-jwt/$JWT_SERVICE_ID authenticator... "
cp policies/policy-jwt-auth.yaml data/policy-jwt-auth.yaml
sed -i "s/\$JWT_SERVICE_ID/$JWT_SERVICE_ID/g" data/policy-jwt-auth.yaml
conjur policy load -b root -f data/policy-jwt-auth.yaml
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

# Loading jwt authentication data
echo "Loading jwt authentication data... "
pub_keys='{"type":"jwks", "value": {"keys":['$(cat $PUB_CRT_FILE.jwks)']}}'
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/public-keys -v "$pub_keys"
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/token-app-property -v host
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/identity-path -v jwt-apps/$JWT_SERVICE_ID
conjur variable set -i conjur/authn-jwt/$JWT_SERVICE_ID/issuer -v $JWT_SERVICE_ISS

# Generating /etc/conjur/config/conjur.yaml file
echo "Generating conjur configuration for authenticators options... "
CONF_FILE=/opt/cyberark/conjur/config/conjur.yml
[ -f "$CONF_FILE" ] && mv $CONF_FILE $CONF_FILE.bk
echo "#This file is created by script: 02.configuring_jwt_script.sh" > $CONF_FILE
echo "authenticators:" >> $CONF_FILE

auth_json=$(curl -sk CONJUR_URL:8443/info | jq '.authenticators')
count=$(echo $auth_json | jq '.configured | length')
for (( i=0; i<$count; i++  )); do
    auth=$(echo $auth_json | jq ".configured[$i]" | tr -d '"')
    echo "Adding auth $i: $auth"
    echo "  - $auth" >> $CONF_FILE
done
echo "Activating authn-jwt/$JWT_SERVICE_ID authenticator..."
$SUDO $CONTAINER_MGR exec conjur evoke configuration apply
[[ $? -eq 0 ]] && echo "Done!!!"  || echo "ERROR!!!"

echo "Double check for the authenticator configuration:"
curl -sk https://gitlab.home.huydo.net:8443/info | jq '.authenticators'

