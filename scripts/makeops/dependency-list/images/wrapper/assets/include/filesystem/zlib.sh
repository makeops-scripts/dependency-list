#!/bin/sh -e

# TODO: Is there a more relaible way of getting zlib version?

# Detect zlib version
version=$(find / -name 'libz.so*' | sort -r | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' ||:)
if [ -z "$version" ]; then
  file=$(find / -name 'zlib.pc')
  if [ -f "$file" ]; then
    version=$(grep "^Version:" $file | awk -F' ' '{ print $2 }')
  fi
fi

# Print output as json to the stdout
if [ -n "$version" ]; then
  printf \
    "{\"name\":\"zlib\",\"version\":\"%s\"}" \
    "$version"
fi
