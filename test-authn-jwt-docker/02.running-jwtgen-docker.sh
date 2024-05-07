#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

source ./00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set +x
node_name=jwtgen
$SUDO $CONTAINER_MGR stop $node_name
$SUDO $CONTAINER_MGR container rm $($SUDO $CONTAINER_MGR ps -a | grep $node_name | awk '{print $1}')

rm data/*
# Preparing jwt header
echo "Generating jwt header... "
cat <<EOF > $JWT_HEADER_FILE
{
    "typ": "JWT",
    "alg": "RS256",
    "kid": "$JWT_KID"
}
EOF

# Preparing jwt payload
echo "Generating jwt payload... "
cat <<EOF > $JWT_PAYLOAD_FILE
{
  "host": "$JWT_HOST_ID",
  "aud": "huy.do/$JWT_SERVICE_ID",
  "name": "$JWT_SERVICE_ID",
  "iss": "$JWT_SERVICE_ISS"
}
EOF

$SUDO $CONTAINER_MGR run \
    --name $node_name \
    --detach \
    --restart=unless-stopped \
    --volume $PWD/data:/etc/jwtgen:z \
    jwtgen
        
set -x
