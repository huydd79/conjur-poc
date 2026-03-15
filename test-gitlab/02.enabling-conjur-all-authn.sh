#!/bin/bash
# -----------------------------------------------------------------------------
# Script: 02.enabling-conjur-all-authn.sh
# Description: Add and enable JWT authenticators dynamically
# Author: Huy Do (huy.do@cyberark.com)
# -----------------------------------------------------------------------------

CONJUR_URL="https://conjur.cybr.huydo.net"
CONF_FILE=/opt/cyberark/conjur/config/conjur.yml
SUDO=
CONTAINER_MGR=docker
JWT_SERVICE_ID="github" 

# Backup existing config
[ -f "$CONF_FILE" ] && cp $CONF_FILE $CONF_FILE.bk.$(date +%s)

echo "Step 1: Fetching current configured authenticators..."
# Fetch existing, add NEW service ID, and ensure unique values using jq
auth_json=$(curl -sk $CONJUR_URL/info | jq -c ".authenticators.configured + [\"authn-jwt/$JWT_SERVICE_ID\"] | unique")

if [[ -z "$auth_json" || "$auth_json" == "null" ]]; then
    echo "ERROR: Could not fetch current configuration. Check Conjur connectivity."
    exit 1
fi

echo "Step 2: Updating $CONF_FILE with: $auth_json"
cat << EOF > $CONF_FILE
# This file is created by script $0
authenticators: $auth_json
EOF

echo "Step 3: Applying configuration via evoke..."
$SUDO $CONTAINER_MGR exec conjur evoke configuration apply

if [[ $? -eq 0 ]]; then
    echo "Step 4: Waiting for services to stabilize (10s)..."
    sleep 10 
    
    echo "Double check for the authenticator configuration:"
    curl -sk $CONJUR_URL/info | jq '.authenticators'
    echo "Done!!!"
else
    echo "ERROR: Configuration apply failed!"
    exit 1
fi