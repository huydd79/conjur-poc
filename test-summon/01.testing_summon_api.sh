#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

if [ ! -f "../test-authn-apikey/user.conf" ]; then
    echo "Please create user.conf file with your Conjur user and API key before running this script"
    exit
fi

source ../test-authn-apikey/user.conf

# System variables
CONJUR_VAR_PASSWORD="test/host1/pass"
export CONJUR_APPLIANCE_URL="https://conjur.$POC_DOMAIN:$POC_CONJUR_HTTPS_PORT"
export CONJUR_ACCOUNT="CYBR"
export CONJUR_CERT_FILE="./conjur-server.pem"
export CONJUR_AUTHN_LOGIN="$USER"
export CONJUR_AUTHN_API_KEY="$KEY"

# --- Certificate Generation Logic ---
if [ ! -f "$CONJUR_CERT_FILE" ]; then
    echo "Certificate $CONJUR_CERT_FILE not found. Fetching from $CONJUR_APPLIANCE_URL..."
    
    # Extract the hostname and port from the URL
    HOST=$(echo $CONJUR_APPLIANCE_URL | awk -F[/:] '{print $4}')
    PORT=$(echo $CONJUR_APPLIANCE_URL | awk -F[/:] '{print $5}')
    
    # Use openssl to fetch the certificate
    openssl s_client -showcerts -connect "$HOST:$PORT" < /dev/null 2> /dev/null | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$CONJUR_CERT_FILE"
    
    if [ -s "$CONJUR_CERT_FILE" ]; then
        echo "Successfully created $CONJUR_CERT_FILE"
    else
        echo "Error: Failed to fetch certificate. Please check your Conjur URL or network connection."
        exit 1
    fi
fi
# ------------------------------------

set -x

# Invoke Summon
summon --yaml "PASSWORD: !var test/host1/pass" ./test.sh

set +x