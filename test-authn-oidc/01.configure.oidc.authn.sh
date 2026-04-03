#!/bin/bash

# Load configurations
source ./00.config.sh

# Check if configuration is ready
if [[ "$READY" != true ]]; then
    echo "Error: Configuration is not ready. Please set READY=true in 00.config.sh."
    exit 1
fi

# 1. Loading the Service Policy
echo "Step 1: Loading OIDC Service Policy (oidc-authn-policy.yaml)..."
conjur policy load -b root -f oidc-authn-policy.yaml
if [[ $? -ne 0 ]]; then echo "ERROR: Failed to load policy."; exit 1; fi

# 2. Setting Configuration Variables
echo "Step 2: Setting OIDC Configuration Variables for '$SERVICE_ID'..."
conjur variable set -i "$AUTHENTICATOR_ID/provider-uri" -v "$OIDC_PROVIDER_URI"
conjur variable set -i "$AUTHENTICATOR_ID/client-id" -v "$OIDC_CLIENT_ID"
conjur variable set -i "$AUTHENTICATOR_ID/client-secret" -v "$OIDC_CLIENT_SECRET"
conjur variable set -i "$AUTHENTICATOR_ID/redirect-uri" -v "$OIDC_REDIRECT_URI_UI"
conjur variable set -i "$AUTHENTICATOR_ID/claim-mapping" -v "$OIDC_CLAIM_MAPPING"

# Optional: CA Cert & TTL
[[ -n "$OIDC_TOKEN_TTL" ]] && conjur variable set -i "$AUTHENTICATOR_ID/token-ttl" -v "$OIDC_TOKEN_TTL"
[[ -f "$OIDC_CA_CERT_PATH" ]] && conjur variable set -i "$AUTHENTICATOR_ID/ca-cert" -v "$(cat $OIDC_CA_CERT_PATH)"

# 3. Enabling Authenticator in Conjur Configuration
echo "Step 3: Enabling '$AUTHENTICATOR_NAME' in conjur.yml..."
CONF_FILE=/opt/cyberark/conjur/config/conjur.yml
current_authn=$(curl -sk "$CONJUR_URL/info" | jq -r '.authenticators.enabled | join(",")')

if [[ "${current_authn}" != *"${AUTHENTICATOR_NAME}"* ]]; then
    NEW_LIST=$(echo "$current_authn,$AUTHENTICATOR_NAME" | sed 's/^,//')
    sudo bash -c "echo 'authenticators: [$NEW_LIST]' > $CONF_FILE"
else
    echo "✓ Authenticator '$AUTHENTICATOR_NAME' is already enabled in config."
fi

# 4. Apply Configuration
echo "Step 4: Applying configuration..."
sudo docker exec conjur evoke variable unset CONJUR_AUTHENTICATORS
sudo docker exec conjur evoke configuration apply

echo "Authenticator '$SERVICE_ID' is now CONFIGURED and ENABLED."
sleep 5

# 5. Verification
echo "--------------------------------------------------------"
echo "Double checking authenticator status:"
curl -sk $CONJUR_URL/info | jq '.authenticators'
