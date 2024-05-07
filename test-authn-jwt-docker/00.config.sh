#!/bin/bash

source ../00.config.sh

#Change your configuration and set READY=true when done
READY=true

#JWT Setting
JWT_HOST_ID=$(hostname)
JWT_KID=$(hostname | sha1sum | awk '{print $1}')

JWT_HEADER_FILE=data/jwt_header.json
JWT_PAYLOAD_FILE=data/jwt_payload.json
JWT_SERVICE_ID=testjwt-docker
JWT_SERVICE_ISS=https://jwt.home.huydo.net

