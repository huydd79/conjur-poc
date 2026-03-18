#!/bin/bash

source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

mkdir -p data


# --- Key Persistence Logic ---
SHOULD_GENERATE=true

# Check if both key and cert exist
if [[ -f "$PRV_KEY_FILE" && -f "$PUB_KEY_FILE" ]]; then
    echo "--- Existing key pair found. Checking validity. ---"
    
    # Extract modulus from Public Key (note the -pubin flag)
    PUB_MODULUS=$(openssl rsa -pubin -noout -modulus -in "$PUB_KEY_FILE" 2>/dev/null | openssl md5)
    
    # Extract modulus from Private Key
    PRIV_MODULUS=$(openssl rsa -noout -modulus -in "$PRV_KEY_FILE" 2>/dev/null | openssl md5)

    if [[ -n "$PUB_MODULUS" && "$PUB_MODULUS" == "$PRIV_MODULUS" ]]; then
        echo "--- Existing key pair is valid. Skipping generation. ---"
        SHOULD_GENERATE=false
    else
        echo "--- Existing key pair is invalid, mismatched or corrupted. Re-generating ---"
        SHOULD_GENERATE=true
    fi
fi

if [ "$SHOULD_GENERATE" = true ]; then
    echo "--- Key pair is not existed. Generating new one. ---" 
    # Generating key pair
    openssl genrsa -out $PRV_KEY_FILE 4096
    openssl rsa -in $PRV_KEY_FILE -pubout -out $PUB_KEY_FILE
    [[ $? -eq 0 ]] && echo "--- Key pair created successfully. ---"  || echo "ERROR!!!"
    #rm /tmp/cert-tmp.conf
    chmod -R 600 $PRV_KEY_FILE
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
#./tools/pem2jwks.py $PUB_CRT_FILE $JWT_KID > $PUB_CRT_FILE.jwks
./tools/pubkey2jwks.py $PUB_KEY_FILE $JWT_KID > $PUB_JWKS_FILE

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


