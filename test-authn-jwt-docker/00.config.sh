#!/bin/bash

source ../00.config.sh

#Change your configuration and set READY=true when done
READY=true

#JWT Setting
JWT_HOST_ID=$(hostname)
JWT_KID=$(hostname | sha1sum | awk '{print $1}')
JWT_EXPIRE=600 # in seconds, default is 3600s = 1h

JWT_HEADER_FILE=data/jwtgen/jwt_header.json
JWT_PAYLOAD_FILE=data/jwtgen/jwt_payload.json
JWT_SERVICE_ID=testjwt-docker
JWT_SERVICE_ISS=https://jwt.home.huydo.net

