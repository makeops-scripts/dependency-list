#!/bin/sh

# Proceed only if the image is Python-enabled
python=$(which python 2> /dev/null)
[ -z "$python" ] && python=$(find / -type f -executable -name 'python' 2> /dev/null | head -n 1)
[ -z "$python" ] && python=$(which python3 2> /dev/null)
[ -z "$python" ] && python=$(find / -type f -executable -name 'python3' 2> /dev/null | head -n 1)
[ -z "$python" ] && exit 0

# Find out Python version and package dependencies
version="$($python --version 2>&1 | grep -i python | awk '{ print $2 }')"
# Search for package dependencies
dep_list=$(
  $python -m pip list 2> /dev/null | while read -r line; do
    echo "$line" | grep -qi ^package && continue
    echo "$line" | grep -q ^- && continue
    pkg=$(echo "$line" | awk '{ print $1 }')
    ver=$(echo "$line" | awk '{ print $2 }')
    printf \
      "{\"Name\":\"%s\",\"Version\":\"%s\"}," \
      "$pkg" "$ver"
  done | head -c -1
)
dependencies=
if [ -n "$dep_list" ]; then
  dependencies=$(printf ",\"Dependencies\":[%s]" "$dep_list")
fi

# Print output as json to the stdout
printf \
  "{\"Name\":\"python\",\"Version\":\"%s\"%s}" \
  "$version" "$dependencies"
