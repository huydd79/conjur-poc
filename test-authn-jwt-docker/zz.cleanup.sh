#!/bin/bash

source ../00.config.sh
if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

node_name=jwtgen

$SUDO $CONTAINER_MGR stop $node_name
$SUDO $CONTAINER_MGR container rm $($SUDO $CONTAINER_MGR ps -a | grep $node_name | awk '{print $1}')

rm -f data/*
