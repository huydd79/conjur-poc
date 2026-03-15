#!/bin/bash
# Script to generate RSA keys for encryption testing

mkdir -p ./test_data/output

# 1. Generate a 2048-bit RSA private key
openssl genrsa -out ./test_data/private_key.pem 2048

# 2. Extract the public key (This will be mounted into the container)
openssl rsa -in ./test_data/private_key.pem -pubout -out ./test_data/public_key.pem

echo "RSA Keys generated in ./test_data/"
echo "Note: public_key.pem will be used to encrypt the secret inside the container."