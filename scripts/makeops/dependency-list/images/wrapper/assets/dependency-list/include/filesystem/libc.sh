#!/bin/sh

# Detect libc version
if ldd --version > /dev/null 2>&1; then

  version=$(ldd --version 2> /dev/null | grep -Eo '[0-9]+\.[0-9]+[\.]?[0-9]*' | head -n 1)
  # Print output as json to the stdout
  if [ -n "$version" ]; then
    printf \
      "{\"Name\":\"libc\",\"Version\":\"%s\"}" \
      "$version"
  fi

# Detect musl version
elif apk info musl > /dev/null 2>&1; then

  version=$(apk info musl 2> /dev/null | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+[-]?[a-z]?[0-9]?' | head -n 1)
  # Print output as json to the stdout
  if [ -n "$version" ]; then
    printf \
      "{\"Name\":\"musl\",\"Version\":\"%s\"}" \
      "$version"
  fi

fi
