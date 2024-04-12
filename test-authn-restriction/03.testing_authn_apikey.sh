#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

if [ ! -f "host.conf" ]; then
    echo "Please generate user.conf before running this script"
    exit
fi

source ./host.conf

CONJUR_URL="https://$CONJUR_IP:$POC_CONJUR_HTTPS_PORT"

AUTH_TOKEN=$(curl -sk --request POST $CONJUR_URL/authn/$POC_CONJUR_ACCOUNT/$HOST/authenticate \
		  --data-raw "$KEY")

if [ -z "$AUTH_TOKEN" ]; then
    echo "Authentication FAILED!!!"
else
    echo "Authentication SUCCESS!!!"
    echo $AUTH_TOKEN | jq
    echo "Copy below curl command and execute from another machine to see diffirent"
    echo "================="
    echo "curl -sk --request POST $CONJUR_URL/authn/$POC_CONJUR_ACCOUNT/$HOST/authenticate --data-raw \"$KEY\""
    echo "================="
fi

