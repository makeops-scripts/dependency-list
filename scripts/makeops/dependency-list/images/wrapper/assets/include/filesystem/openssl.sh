#!/bin/sh -e

# TODO: Do `gnutls` and `libressl` need to be recognised?

# Detect openssl version
version="$(openssl version 2> /dev/null | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+[a-z]?' ||:)"
if [ -z "$version" ]; then
  file=$(ls -1 /lib/libssl* | head -n 1)
  if [ -f "$file" ]; then
    version="$(strings $file | grep -i "^openssl " | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+[a-z]?' ||:)"
  fi
fi

# Print output as json to the stdout
if [ -n "$version" ]; then
  printf \
    "{\"name\":\"openssl\",\"version\":\"%s\"}" \
    "$version"
fi
