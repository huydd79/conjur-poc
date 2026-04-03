#!/bin/bash

# Load configurations
source ./00.config.sh

# Check if configuration is ready
if [[ "$READY" != true ]]; then
    echo "Error: Configuration is not ready. Please set READY=true in 00.config.sh."
    exit 1
fi

echo "========================================================================"
echo "OIDC AUTHENTICATOR STATUS CHECK"
echo "========================================================================"
echo ""

# 1. Get current user
echo "Step 1: Getting current user..."
CONJUR_USER=$(conjur whoami 2>/dev/null | jq -r '.username')

if [[ -z "$CONJUR_USER" || "$CONJUR_USER" == "null" ]]; then
    echo "✗ Conjur is not logged in. Please run 'conjur login -i <user> -p <pass>' first."
    exit 1
fi

echo "✓ Current user: $CONJUR_USER"
echo ""

# 3. Rotate API key and get new key
echo "Step 3: Rotating API key..."
NEW_API_KEY=$(conjur user rotate-api-key 2>&1)

if [[ -z "$NEW_API_KEY" ]]; then
    echo "✗ Failed to rotate API key."
    exit 1
fi

echo "✓ New API key obtained."
echo ""

# 4. Authenticate with new API key
echo "Step 4: Authenticating with new API key..."
conjur login -i "$CONJUR_USER" -p "$NEW_API_KEY" > /dev/null 2>&1

if [[ $? -ne 0 ]]; then
    echo "✗ Login with new API key failed."
    exit 1
fi

echo "✓ Login successful."
echo ""

# 5. Get access token
echo "Step 5: Getting access token..."
AUTH_TOKEN=$(conjur authenticate 2>&1)

if [[ -z "$AUTH_TOKEN" ]]; then
    echo "✗ Failed to get access token."
    exit 1
fi

echo "✓ Access token obtained."

echo ""

# 6. Encode token and check OIDC authenticator status
echo "Step 6: Encoding token to base64 and checking status..."
STATUS_ENDPOINT="$CONJUR_URL/$AUTHENTICATOR_NAME/$CONJUR_ACCOUNT/status"
AUTH_TOKEN_B64=$(printf '%s' "$AUTH_TOKEN" | base64 -w 0)
STATUS_HEADER="Token token=\"$AUTH_TOKEN_B64\""

STATUS_RESPONSE=$(curl -sk \
    -H "authorization: $STATUS_HEADER" \
    -H "content-type: text/plain" \
    "$STATUS_ENDPOINT" 2>&1)
STATUS_HTTP=$(curl -sk -o /dev/null -w "%{http_code}" \
    -H "authorization: $STATUS_HEADER" \
    -H "content-type: text/plain" \
    "$STATUS_ENDPOINT" 2>&1)

echo "API Endpoint: $STATUS_ENDPOINT"
echo "HTTP Status: $STATUS_HTTP"
echo ""

if [[ "$STATUS_HTTP" == "200" ]]; then
    echo "✓ OIDC Authenticator status check successful"
    echo "Response:"
    echo "$STATUS_RESPONSE" | jq . 2>/dev/null || echo "$STATUS_RESPONSE"
else
    echo "✗ OIDC Authenticator status check failed (HTTP $STATUS_HTTP)"
    echo "Response: $STATUS_RESPONSE"
    exit 1
fi

echo ""
echo "========================================================================"
echo "Next steps:"
echo "  1. Test OIDC login via UI: $CONJUR_URL/ui"
echo "  2. Configure you IDP for authentication and OIDC claim mapping"
echo "========================================================================"
