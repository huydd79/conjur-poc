#!/bin/bash

source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

mkdir -p data

if [ ! -f $PRV_KEY_FILE ]; then
    echo "Key pair is not existed. Generating new one... " 
    # Generating key pair
    cat <<EOF > /tmp/cert-tmp.conf
[req]
distinguished_name = HUYDO-LAB
req_extensions = v3_req
prompt = no
[HUYDO-LAB]
C = VN
ST = Hanoi
L = Hanoi
O = huydo.net
OU = cybr
CN = HUYDO-LAB
[v3_req]
EOF

    openssl genrsa -aes256 -passout pass:changeme -out $PRV_KEY_FILE.pass.key 4096
    openssl rsa -passin pass:changeme -in $PRV_KEY_FILE.pass.key -out $PRV_KEY_FILE
    openssl req -new -x509 -days 3650 -key $PRV_KEY_FILE -out $PUB_CRT_FILE -config /tmp/cert-tmp.conf
    [[ $? -eq 0 ]] && echo "Key pair created successfully."  || echo "ERROR!!!"
    rm /tmp/cert-tmp.conf
    chmod -R 600 /etc/ssl/private
fi


# Preparing jwt header
echo -n "Generating jwt header... "
cat <<EOF > $JWT_HEADER_FILE
{
    "typ": "JWT",
    "alg": "RS256",
    "kid": "$JWT_KID"
}
EOF

[[ $? -eq 0 ]] && echo "done."  || echo "ERROR!!!"

# Converting public cert to jwks format
echo -n "Generating jwks file... "
./tools/pem2jwks.py $PUB_CRT_FILE $JWT_KID > $PUB_CRT_FILE.jwks
if [[ $? -eq 0 ]]; then
    echo "done. JWKS content as below:"
    echo "==========================="
    cat $PUB_CRT_FILE.jwks
    echo "==========================="
else
    echo "ERROR!!!"
    exit
fi

# Preparing jwt payload
echo -n "Generating jwt payload... "
cat <<EOF > $JWT_PAYLOAD_FILE
{
  "host": "$JWT_HOST_ID",
  "aud": "huy.do/$JWT_SERVICE_ID",
  "name": "$JWT_SERVICE_ID",
  "iss": "$JWT_SERVICE_ISS"
}
EOF
[[ $? -eq 0 ]] && echo "done."  || echo "ERROR!!!"

# Creating jwt
echo -n "Generating jwt file: $JWT_FILE ..."
./tools/jwtgen.sh $JWT_HEADER_FILE $JWT_PAYLOAD_FILE $PRV_KEY_FILE > $JWT_FILE
if [[ $? -eq 0 ]]; then
    echo "done. JWT content as below:"
    echo "==========================="
    cat $JWT_FILE
    echo "==========================="
else
    echo "ERROR!!!"
    exit
fi


