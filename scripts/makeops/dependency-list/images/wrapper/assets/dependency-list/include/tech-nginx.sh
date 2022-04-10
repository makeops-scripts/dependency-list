#!/bin/sh

# Proceed only if the image is JavaScript-enabled
nginx=$(which nginx 2> /dev/null)
[ -z "$nginx" ] && nginx=$(find / -type f -executable -name 'nginx' 2> /dev/null | head -n 1)
[ -z "$nginx" ] && exit 0

# List dynamic modules
version="$(nginx -v 2>&1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+[a-z]?')"
mod_list=$(
  nginx -V 2>&1 | tr -- - '\n' | grep -v '=' | grep '_module' | while read -r name; do
    printf \
      "{\"Name\":\"%s\"}," \
      "$name"
  done | head -c -1
)
dependencies=
if [ -n "$mod_list" ]; then
  dependencies=$(printf ",\"Dependencies\":[%s]" "$mod_list")
fi

# Print output as json to the stdout
printf \
  "{\"Name\":\"nginx\",\"Version\":\"%s\"%s}" \
  "$version" "$dependencies"
