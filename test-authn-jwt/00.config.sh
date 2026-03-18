#!/bin/bash

#Change your configuration and set READY=true when done
READY=true

#JWT Setting
JWT_HOST_ID=$(hostname)

JWT_KID=$(hostname | sha1sum | awk '{print $1}')

PRV_KEY_FILE=data/jwtgen_prv.pem
PUB_KEY_FILE=data/jwtgen_pub.pem
PUB_JWKS_FILE=data/jwtgen.jwks

JWT_HEADER_FILE=data/jwt_header.json
JWT_PAYLOAD_FILE=data/jwt_payload.json
JWT_FILE=data/jwt
JWT_SERVICE_ID=testjwt
JWT_SERVICE_ISS=https://jwt.home.huydo.net

