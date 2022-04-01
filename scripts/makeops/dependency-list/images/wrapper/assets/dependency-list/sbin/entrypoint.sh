#!/bin/sh -e

if echo "$*" | grep -q -- "--tech"; then

  # Detect the filesystem and print output as json to the stdout
  printf "{\"Filesystem\":%s} " "$(/dependency-list/include/filesystem.sh)"

  # Find out selected tech dependencies
  tech="$(echo "$*" | awk '{ print $2 }')"
  output=$(
    for script in $(echo "$tech" | sed "s/,/ /g"); do
      name=$script
      [ "$name" = "filesystem" ] && continue
      tech=$("/dependency-list/include/tech-${name}.sh")
      if [ -n "$tech" ]; then
        printf "%s," "$tech"
      fi
    done
  )
  # Print output as json to the stdout
  if [ -n "$output" ]; then
    printf "{\"Tech\":[%s]} " "$(printf "%s" "$output" | head -c -1)"
  fi

elif [ -z "$*" ]; then

  # Detect the filesystem and print output as json to the stdout
  printf "{\"Filesystem\":%s} " "$(/dependency-list/include/filesystem.sh)"

  # Find out all the tech dependencies
  output=$(
    for script in /dependency-list/include/tech-*.sh; do
      name=$(basename "$script" .sh | sed "s/tech-//")
      [ "$name" = "filesystem" ] && continue
      tech=$("/dependency-list/include/tech-${name}.sh")
      if [ -n "$tech" ]; then
        printf "%s," "$tech"
      fi
    done
  )
  # Print output as json to the stdout
  if [ -n "$output" ]; then
    printf "{\"Tech\":[%s]} " "$(printf "%s" "$output" | head -c -1)"
  fi

else

  # Run a custom command
  $*

fi
