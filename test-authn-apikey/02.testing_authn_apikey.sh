#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

if [ ! -f "user.conf" ]; then
    echo "Please generate user.conf before running this script"
    exit
fi

source ./user.conf

CONJUR_VAR_PASSWORD="test/host1/pass"
CONJUR_URL="https://conjur.$POC_DOMAIN:$POC_CONJUR_HTTPS_PORT"

set -x

AUTH_TOKEN=$(curl -sk --request POST $CONJUR_URL/authn/$POC_CONJUR_ACCOUNT/$USER/authenticate \
		  --data-raw "$KEY"|base64 -w 0)
echo 
PASSWORD=$(curl -sk --request GET $CONJUR_URL/secrets/$POC_CONJUR_ACCOUNT/variable/$CONJUR_VAR_PASSWORD \
		--header "Authorization: Token token=\"$AUTH_TOKEN\"")
echo
echo "PASSWORD=$PASSWORD"

set +x