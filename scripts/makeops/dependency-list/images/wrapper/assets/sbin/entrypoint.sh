#!/bin/sh -e

if echo "$*" | grep -q -- "--tech"; then

  tech="$(echo "$*" | awk '{ print $2 }')"

  # Find out selected tech dependencies, including the filesystem
  output=$(
    printf "{\"filesystem\":%s} " "$(/include/filesystem.sh)"
    for script in $(echo "$tech" | sed "s/,/ /g"); do
      name=$script
      dependencies=$("/include/tech-${script}.sh")
      if [ -n "$dependencies" ]; then
        printf "{\"tech\":{\"%s\":%s}} " "$name" "$dependencies"
      fi
    done | head -c -1
  )

  # Print output as json to the stdout
  printf "%s" "$output"

elif [ -z "$*" ]; then

  # Find out all the tech dependencies
  output=$(
    printf "{\"filesystem\":%s} " "$(/include/filesystem.sh)"
    for script in /include/tech-*.sh; do
      name=$(basename "$script" .sh | sed "s/tech-//")
      [ "$name" = "filesystem" ] && continue
      dependencies=$($script)
      if [ -n "$dependencies" ]; then
        printf "{\"tech\":{\"%s\":%s}} " "$name" "$dependencies"
      fi
    done | head -c -1
  )

  # Print output as json to the stdout
  printf "%s" "$output"

else

  # Run a custom command
  $*

fi
