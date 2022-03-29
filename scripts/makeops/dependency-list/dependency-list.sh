#!/bin/bash -e

# ?
#
# Usage:
#   $ ?

# ==============================================================================

IMAGE_SUFFIX=${IMAGE_SUFFIX:-dl}
SCRIPT_DIR=$([ -n "${BASH_SOURCE[0]}" ] && cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd || dirname "$(readlink -f "$0")")
OUTPUT_DIR=${OUTPUT_DIR:-$SCRIPT_DIR/results}
#OUTPUT_FILE=

# ==============================================================================
# Public functions

function dependency-list() { ### Find all the dependencies - mandatory: IMAGE|$1=[image name]; optional: TECH|$2=[technology to search for]

  image="${IMAGE:-$1}"
  tech="${TECH:-$2}"

  [[ ! "$image" =~ ^makeops/dependency-list/* ]] && docker pull "$image"
  wrap-image "$image"

  _json_clean
  search-for-dependencies "$image" "$tech"
  fetch-configuration-info "$image"
  fetch-image-info "$image"
  _json_print
}

function dependency-list-clean() { ### Clean up

  rm -f "$SCRIPT_DIR"/images/wrapper/Dockerfile.effective
  rm -f "$OUTPUT_DIR"/*.json
  docker image rm --force $(docker images | grep -- "-$IMAGE_SUFFIX" | awk '{ print $3 }' 2> /dev/null) 2> /dev/null ||:
  docker image rm --force $(docker images --filter "dangling=true" --quiet) 2> /dev/null ||:
}

# ==============================================================================
# Protectd functions

function wrap-image() { ### Wrap the image to allow to run the dependency list scripts - mandatory: $1 [image name]

  image="$1"
  (
    cd "$SCRIPT_DIR"/images/wrapper
    sed "s;\${IMAGE};${image};g" Dockerfile > Dockerfile.effective
    docker build --rm \
      --file Dockerfile.effective \
      --tag "${image}-${IMAGE_SUFFIX}" \
      .
  )
}

function search-for-dependencies() { ### Search for dependencies including filesystem - mandatory: $1 [image name]; optional: $2 [technology to search for]

  image="$1"
  tech="$(if [ -n "$2" ]; then echo "--tech $2"; fi)"

  output=$(docker run --rm "${image}-${IMAGE_SUFFIX}" "$tech")

  _json_add "$output"
}

function fetch-configuration-info() { ###  Fetch information about the project - mandatory: $1 [image name]

  image="$1"

  output=$(
    docker image inspect --format="{{json .Config.Env }}" "$image" \
      | jq -r '.[]' \
      | grep -E '^(BUILD_|PROJECT_|SERVICE_)' \
      | awk '{sub(/=/," ");$1=$1;print $1,$2}' \
      | awk '{ printf "\"%s\":\"%s\",", $1,$2 }' \
      | head -c -1
  )

  if [ -n "$output" ]; then
    _json_add "{\"configuration\":{$output}} "
  fi
}

function fetch-image-info() { ### Feth information about the image - mandatory: $1 [image name]

  image="$1"

  data=$(docker image inspect --format="{{ .Id }},{{ .Architecture }},{{ .Created }},{{ .Size }}" "$image")
  IFS=',' read -a data <<< "$data"
  i=0
  layers=$(
    IFS=$'\n';
    for layer in $(docker history --format '{{ .CreatedBy }}' --no-trunc "$image" | tac); do
      i=$((i + 1))
      printf "\"%s\":\"%s\"," "$i" "$(echo "$layer" | sed 's/\/bin\/sh -c[ \t]*#(nop)[ \t]*//' | sed 's/\\/\\\\\\\\/g' | sed 's/"/\\\\"/g')"
    done | head -c -1
  )

  _json_add "{\"image\":{\"name\":\"$image\",\"digest\":\"${data[0]}\",\"architecture\":\"${data[1]}\",\"date\":\"${data[2]}\",\"size\":${data[3]},\"layers\":{$layers}}} "
}

# ==============================================================================
# Private functions

function _json_clean() {

  if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE=$(docker image inspect --format="{{ .Id }}.json" "$IMAGE" | sed "s/sha256://")
  fi
  rm -f "$OUTPUT_DIR/$OUTPUT_FILE"
}

function _json_add() {

  printf "$*" >> "$OUTPUT_DIR/$OUTPUT_FILE"
}

function _json_print() {

  _json_sanitise
  printf "\nFILE: %s\n" "$OUTPUT_DIR/$OUTPUT_FILE"
  jq . < "$OUTPUT_DIR/$OUTPUT_FILE"
}

function _json_sanitise() {

  cat "$OUTPUT_DIR/$OUTPUT_FILE" | tr -d '\n' | tr -d '\r' | jq -s add > "$OUTPUT_DIR/$OUTPUT_FILE.tmp"
  mv -f "$OUTPUT_DIR/$OUTPUT_FILE.tmp" "$OUTPUT_DIR/$OUTPUT_FILE"
}

# ==============================================================================

export -f dependency-list
export -f dependency-list-clean
