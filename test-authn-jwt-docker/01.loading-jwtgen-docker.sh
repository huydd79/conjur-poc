#!/bin/bash

source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set +x

$SUDO $CONTAINER_MGR load -i image/jwtgen.tar.gz
$SUDO $CONTAINER_MGR image ls

set -x
