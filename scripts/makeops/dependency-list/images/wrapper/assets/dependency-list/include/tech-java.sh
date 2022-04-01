#!/bin/sh

# TODO: If it is a JRE distribution then there is no `jar` command and therefore no easy way to list the dependencies

# Proceed only if the image is Java-enabled
java=$(which java 2> /dev/null)
[ -z "$java" ] && java=$(find / -type f -executable -name 'java' 2> /dev/null | head -n 1)
[ -z "$java" ] && exit 0
jar=$(which jar 2> /dev/null)
[ -z "$jar" ] && jar=$(find / -type f -executable -name 'jar' 2> /dev/null | head -n 1)

# Find out Java version
version="$($java -version 2>&1 | awk -F '"' '/version/ { print $2 }')"
# Search for package dependencies
dep_list=$(
  for file in $(find / -not \( -path /usr/local -prune \) -not \( -path /usr/share -prune \) -not \( -path /usr/lib -prune \) -name '*.jar' 2> /dev/null); do
    for dependency in $($jar -tf $file 2> /dev/null | grep .jar$ | awk '{ print $NF }'); do
      str=$(basename $dependency | sed "s/.jar//" | sed "s/[\.A-Za-z-]*$//")
      ver=$(echo $str | rev | cut -d- -f1 | rev)
      lib=$(echo $str | sed "s/-${ver}//")
      printf \
        "{\"Name\":\"%s\",\"Version\":\"%s\"}," \
        "$lib" "$ver"
    done
  done | head -c -1
)
dependencies=
if [ -n "$dep_list" ]; then
  dependencies=$(printf ",\"Dependencies\":[%s]" "$dep_list")
fi
# Get distribution name
distribution=$([ -n "$jar" ] && echo "jdk" || echo "jre")

# Print output as json to the stdout
printf \
  "{\"Name\":\"java\",\"Version\":\"%s\",\"Distribution\":\"%s\"%s}" \
  "$version" "$distribution" "$dependencies"
