#!/bin/bash

set +x
openssl rsautl -decrypt -inkey ./test_data/private_key.pem -in ./test_data/output/secret.json.enc

set -x
