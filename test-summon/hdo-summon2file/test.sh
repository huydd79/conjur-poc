#!/bin/bash
# test.sh

# Create a JSON structure with the secret
JSON_DATA=$(printf '{"timestamp": "%s", "secret_value": "%s"}' "$(date)" "$PASSWORD")

# Encrypt the JSON data using the provided public key
echo "$JSON_DATA" | openssl pkeyutl -encrypt -pubin -inkey /app/public_key.pem -out /app/output/secret.json.enc

echo "Success: Secret has been retrieved and encrypted to /app/output/secret.json.enc"