#!/bin/sh -e

# Proceed only if the image is Python-enabled
if ! which python > /dev/null 2>&1; then
  exit 0
fi

# Find out Python version and package dependencies
version="$(python --version 2>&1 | grep -i python | awk '{ print $2 }')"
dependencies=$(
  pip list 2> /dev/null | while read -r line; do
    echo "$line" | grep -qi ^package && continue
    echo "$line" | grep -q ^- && continue
    pkg=$(echo "$line" | awk '{ print $1 }')
    ver=$(echo "$line" | awk '{ print $2 }')
    printf "{\"name\":\"%s\",\"version\":\"%s\"}," "$pkg" "$ver"
  done | head -c -1
)

# Print output as json to the stdout
printf \
  "{\"version\":\"%s\",\"dependencies\":[%s]}" \
  "$version" "$dependencies"
