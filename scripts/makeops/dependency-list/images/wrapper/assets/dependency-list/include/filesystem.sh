#!/bin/sh

# Detect os filesystem using the `system-detect` utility
eval "$(/dependency-list/lib/system-detect.sh)"

# Detect selected system packages
dep_list=
for pkg in openssl libc zlib; do
  output="$(/dependency-list/include/filesystem/$pkg.sh)"
  if [ -n "$output" ]; then
    dep_list=$(printf "%s,%s" "$dep_list" "$output")
  fi
done
dependencies=
if [ -n "$dep_list" ]; then
  dependencies=$(printf ",\"Dependencies\":[%s]" "$(echo "$dep_list" | tail -c +2)")
fi

# Print output as json to the stdout
printf \
  "{\"Type\":\"%s\",\"Name\":\"%s\",\"Version\":\"%s\"%s}" \
  "$SYSTEM_NAME" "$SYSTEM_DIST" "$SYSTEM_VERSION" "$dependencies"
