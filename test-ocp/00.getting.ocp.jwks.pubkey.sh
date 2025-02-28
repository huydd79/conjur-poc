#!/bin/bash


set -x
PUBLIC_KEYS="$(oc get --raw $(oc get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') | base64)"
ISSUER="$(oc get --raw /.well-known/openid-configuration | jq -r '.issuer')"

echo "#NOTE: If you are unable to run oc admin command from this machine. Please get below values from ocp team and mannualy put here" > ocp.conf
echo "PUBLIC_KEYS=$PUBLIC_KEY" >> ocp.conf
echo "ISSUER=$ISSUER" >> ocp.conf

set +x
