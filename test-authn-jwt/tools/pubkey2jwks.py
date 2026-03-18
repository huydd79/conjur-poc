#!/usr/bin/python3

"""
HuyDo@cyberark.com
JWKS Generator Tool
-------------------
This script converts a PEM-encoded Public Key into a JWK (JSON Web Key) format.

Input Requirements:
1. file_path: Path to a PEM file containing a Public Key 
   (e.g., starts with -----BEGIN PUBLIC KEY-----).
2. kid: A unique String to identify this key (Key ID).
3. use: (Optional) The intended use of the public key. 
   Defaults to 'sig' (signature).

Output:
- A JSON-formatted JWK printed to stdout.
"""

import json
import sys
from jose import constants, jwk
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
        # 1. Read the raw PEM data
        try:
            with open(file_path, 'rb') as f:
                self._key_pem_raw_data: bytes = f.read().strip()
        except FileNotFoundError:
            print(f"Error: File not found at {file_path}", file=sys.stderr)
            sys.exit(1)

        # 2. Validate Public Key format
        try:
            serialization.load_pem_public_key(self._key_pem_raw_data, default_backend())
        except Exception as e:
            print(f"Error: Invalid Public Key. {e}", file=sys.stderr)
            sys.exit(1)
            
        self._kid = kid
        self._use = use

    def process(self):
        # 3. Convert PEM to JWK Dictionary
        # Check carefully for closing parentheses here!
        jwks = jwk.RSAKey(
            algorithm=constants.Algorithms.RS256, 
            key=self._key_pem_raw_data
        ).to_dict()

        # 4. Inject metadata
        jwks.update({
            "kid": self._kid,
            "use": self._use,
        })
        
        # Output the JSON
        print(json.dumps(jwks, indent=4))
        return jwks

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: " + sys.argv[0] + " <public_key_file> <kid>", file=sys.stderr)
        sys.exit(1)

    generator = JWKSGenerator(
        file_path=sys.argv[1],
        kid=sys.argv[2],
    )
    generator.process()