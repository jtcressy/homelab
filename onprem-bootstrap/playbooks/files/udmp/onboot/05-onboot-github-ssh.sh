#!/bin/sh
GITHUB_USERNAME=jtcressy
KEYS_B64=$( curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/users/${GITHUB_USERNAME}/keys | jq '.[].key | @base64')
KEYS_FILE="/root/.ssh/authorized_keys"

for key_b64 in $KEYS_B64
do
  key=$(echo $key_b64 | jq -r '@base64d')
  if ! grep -Fxq "$key" "$KEYS_FILE"; then
    echo "$key" >> "$KEYS_FILE"
  fi
done