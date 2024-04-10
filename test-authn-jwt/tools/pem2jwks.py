#!/usr/bin/python3

import base64
import json
import sys

from cryptography.hazmat.primitives.hashes import SHA1
from jose import constants, jwk
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization

class JWKSGenerator:
    def __init__(
        self,
        *,
        file_path: str,
        kid: str,
        use: str = 'sig',
    ) -> None:
        with open(file_path, 'rb') as f:
            self._cert_pem_raw_data: bytes = f.read().strip()

        self._cert = x509.load_pem_x509_certificate(self._cert_pem_raw_data, default_backend())
        self._kid = kid
        self._use = use

    def _create_x5t(self, ):
        digest = self._cert.fingerprint(algorithm=SHA1())
        return base64.b64encode(digest).decode('utf-8')

    def _create_x5c(self, ):
        cert_val = self._cert.public_bytes(serialization.Encoding.DER)
        return base64.b64encode(cert_val).decode('utf-8')

    def process(self):
        jwks = jwk.RSAKey(algorithm=constants.Algorithms.RS256, key=self._cert_pem_raw_data).to_dict()

        jwks.update({
            "kid": self._kid,
            "use": self._use,
        })
        print(json.dumps(jwks, indent=4))
        return jwks

if len(sys.argv) < 2:
    print("Tool to convert key from pem format to jwks:")
    print("usage: " + sys.argv[0] + " pem_file kid")
    sys.exit()

JWKSGenerator(
    file_path=sys.argv[1],
    kid=sys.argv[2],
).process()