#!/bin/bash

# Load configurations
source ./00.config.sh

# Check if configuration is ready
if [[ "$READY" != true ]]; then
    echo "Error: Configuration is not ready. Please set READY=true in 00.config.sh."
    exit 1
fi

# 1. Loading User Policy
echo ">>> Provisioning OIDC Users and Permissions (oidc-users.yaml)..."
conjur policy load -b root -f oidc-users.yaml

if [[ $? -eq 0 ]]; then
    echo "SUCCESS: Policy loaded. User 'huy.do' is ready."
else
    echo "ERROR: Failed to load oidc-users.yaml."
    exit 1
fi

echo ">>> Setup complete."