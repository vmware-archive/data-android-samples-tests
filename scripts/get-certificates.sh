#!/bin/bash

if [ $# -lt 2 ]; then
  echo "";
  echo "USAGE:";
  echo "get-certificates {HOST}:{PORT} {OUTPUT_PATH}";
  echo "";
  exit 1;
fi

HOST_NAME="$1"
OUTPUT_PATH="$2"

mkdir -p "$(dirname "$OUTPUT_PATH")" && touch "$OUTPUT_PATH"

openssl s_client -showcerts -connect $HOST_NAME < /dev/null | openssl x509 -outform DER > $OUTPUT_PATH
