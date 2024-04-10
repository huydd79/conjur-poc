#!/usr/bin/env bash

# 20240404
# Modified by Huy.Do@cyberark.com, adding signature signing using private key
#
# JWT Encoder Bash Script
#
# A lightly modified version of the original by Will Haley:
# https://willhaley.com/blog/generate-jwt-with-bash/
#
# With stdin handling from Filipe Fortes:
# https://fortes.com/2019/bash-script-args-and-stdin/
#

# Copy command-line arguments over to new array
ARGS=( $@ )

# Don't split on spaces
IFS='
'

# Read in from piped input, if present, and append to newly-created array
if [ ! -t 0 ]; then
  readarray STDIN_ARGS < /dev/stdin
  ARGS=( $@ ${STDIN_ARGS[@]} )
fi

# Takes three parameters: the jwt header, jwt payload file and private key file
header_file=${ARGS[0]}

# Take the payload from the arguments, or fall back to stdin
payload_file=${ARGS[1]}

# Take the key file from the arguments, or fall back to stdin
key_file=${ARGS[2]}

# Show an error if neither are defined
if [ -z "$header_file" ] || [ -z "$payload_file" ] || [ -z "$key_file" ]; then
  >&2 echo "Usage: $0 jwt_header_file jwt_payload_file private_key_file"
  exit 1
fi

# Static header fields.
header=$(cat $header_file)

# Use jq to set the dynamic `iat` and `exp`
# fields on the payload using the current time.
# `iat` is set to now, and `exp` is now + 1 hour.
payload=$(
    cat $payload_file | jq --arg time_str "$(date +%s)" \
    '
    ($time_str | tonumber) as $time_num
    | .iat=$time_num
    | .exp=($time_num + 3600)
    '
)

base64_encode() {
    # Use `tr` to URL encode the output from base64.
    base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}

json() {
    jq -c . | tr -d '\n'
}

rsasha256_sign() {
    openssl dgst -sha256 -binary -sign $key_file
}

header_base64=$(echo "${header}" | json | base64_encode)
payload_base64=$(echo "${payload}" | json | base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")
signature=$(echo -n "${header_payload}" | rsasha256_sign | base64_encode)

echo "${header_payload}.${signature}"