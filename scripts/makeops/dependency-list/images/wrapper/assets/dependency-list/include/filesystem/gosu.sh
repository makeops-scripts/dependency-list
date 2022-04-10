#!/bin/sh

# Proceed only if the image is gosu-enabled
gosu=$(which gosu 2> /dev/null)
[ -z "$gosu" ] && gosu=$(find / -type f -executable -name 'gosu' 2> /dev/null | head -n 1)
[ -z "$gosu" ] && exit 0

# Detect gosu version
version="$($gosu --version 2> /dev/null | head -n 1 | awk '{ print $1 }' | grep -Eo '[0-9]+\.[0-9]+\.?[0-9]+[a-z]?')"

# Print output as json to the stdout
printf \
  "{\"Name\":\"gosu\",\"Version\":\"%s\"}" \
  "$version"
