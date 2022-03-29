#!/bin/sh -e

# Detect os filesystem using the `system-detect` utility
eval "$(/lib/system-detect.sh)"

# Detect selected system packages
dependencies=
for pkg in openssl libc zlib; do
  output="$(/include/filesystem/$pkg.sh)"
  if [ -n "$output" ]; then
    dependencies=$(printf "%s,%s" "$dependencies" "$output")
  fi
done
dependencies=$(echo "$dependencies" | tail -c +2)

# Print output as json to the stdout
printf \
  "{\"type\":\"%s\",\"name\":\"%s\",\"version\":\"%s\",\"dependencies\":[%s]}" \
  "$SYSTEM_NAME" "$SYSTEM_DIST" "$SYSTEM_VERSION" "$dependencies"
