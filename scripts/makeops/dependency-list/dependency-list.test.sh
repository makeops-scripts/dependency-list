#!/bin/bash -ex

# ==============================================================================
# Variables

export OUTPUT_DIR=/tmp
export OUTPUT_FILE=dependency-list.log
result=$OUTPUT_DIR/$OUTPUT_FILE

# ==============================================================================
# Public functions

function main() {

  test-python
  test-java
}

# ==============================================================================
# Protected functions

function test-python() {

  make dependency-list IMAGE=python:3.10.4-bullseye
  assert "$result" \
    "linux" "debian" "11.3" "openssl,libc,zlib" \
    "python" "3.10.4" "pip,setuptools,wheel"

  make dependency-list IMAGE=python:3.10.4-slim-bullseye
  assert "$result" \
    "linux" "debian" "11.3" "openssl,libc,zlib" \
    "python" "3.10.4" "pip,setuptools,wheel"

  make dependency-list IMAGE=python:3.10.4-alpine
  assert "$result" \
    "linux" "alpine" "3.15.3" "openssl,musl,zlib" \
    "python" "3.10.4" "pip,setuptools,wheel"

  make dependency-list IMAGE=amazon/aws-lambda-python:3.6.2022.03.23.17
  assert "$result" \
    "linux" "amazon" "202203161534-al2018.03.835.0" "openssl,libc,zlib" \
    "python" "3.6.15" "pip,setuptools"

  make dependency-list IMAGE=makeops/dependency-list/python-app:example
  assert "$result" \
    "linux" "alpine" "3.15.3" "openssl,musl,zlib" \
    "python" "3.10.4" "Django,psycopg2-binary" \
    ".Variables.BUILD_,.Variables.PROJECT_"

  make dependency-list IMAGE=memgraph/memgraph:2.2.1
  assert "$result" \
    "linux" "debian" "11.2" "openssl,libc,zlib" \
    "python" "3.9.2" "decorator,networkx,numpy,pip,scipy,setuptools,wheel"

  # make dependency-list IMAGE=bitnami/python:latest
  # make dependency-list IMAGE=nhsd/python:latest
  # make dependency-list IMAGE=nhsd/python-app:latest
  # make dependency-list IMAGE=nhsd/tools:latest
  # make dependency-list IMAGE=bitnami/airflow:latest
}

function test-java() {

  :

  # make dependency-list IMAGE=openjdk:8-jre
  # make dependency-list IMAGE=openjdk:8-jdk
  # make dependency-list IMAGE=openjdk:11-jre
  # make dependency-list IMAGE=openjdk:11-jdk
  # make dependency-list IMAGE=openjdk:17-jdk-bullseye
  # make dependency-list IMAGE=openjdk:17-jdk-alpine
  # make dependency-list IMAGE=openjdk:19-jdk-bullseye
  # make dependency-list IMAGE=openjdk:19-jdk-alpine

  # make dependency-list IMAGE=adoptopenjdk/openjdk11:debian
  # make dependency-list IMAGE=amazoncorretto:8
  # make dependency-list IMAGE=amazoncorretto:11
  # make dependency-list IMAGE=amazoncorretto:17

  # make dependency-list IMAGE=springio/petclinic:latest
}

# ==============================================================================
# Supporting functions

function assert() {

  # Get arguments
  result="$1"
  filesystem_type="$2"
  filesystem_name="$3"
  filesystem_version="$4"
  filesystem_dependencies="$5"
  tech_name="$6"
  tech_version="$7"
  tech_dependencies="$8"
  variables="$9"

  # Assert .filesystem
  assert-equals "$result" ".Filesystem.Type" "$filesystem_type"
  assert-equals "$result" ".Filesystem.Name" "$filesystem_name"
  assert-equals "$result" ".Filesystem.Version" "$filesystem_version"
  assert-contains "$result" ".Filesystem.Dependencies[] | select(.Version != null) | .Name" "$filesystem_dependencies"

  # Assert .tech
  assert-equals "$result" ".Tech[] | select(.Name ==\"$tech_name\").Name" "$tech_name"
  assert-equals "$result" ".Tech[] | select(.Name ==\"$tech_name\").Version" "$tech_version"
  assert-contains "$result" ".Tech[] | select(.Name ==\"$tech_name\").Dependencies[] | select(.Version != null) | .Name" "$tech_dependencies"

  # Assert .image
  assert-exists "$result" ".Image.Name"
  assert-exists "$result" ".Image.Digest"
  assert-exists "$result" ".Image.Architecture"
  assert-exists "$result" ".Image.Date"
  assert-exists "$result" ".Image.Size"
  assert-exists "$result" ".Image.Layers[]"

  # Assert .variables
  assert-variables "$result" "$variables"
}

function assert-equals() {

  [[ $(jq -r "$2" < "$1") == "$3" ]] && echo return 0 || return 1
}

function assert-contains() {

  output=$(jq -r "$2" < "$1")
  for key in $(echo "$3" | sed "s/,/ /g"); do
    if [[ $output != *${key}* ]]; then
      return 1
    fi
  done

  return 0
}

function assert-exists() {

  [[ -n "$(jq -r "$2" < "$1")" ]] && echo return 0 || return 1
}

function assert-variables() {

  for variable in $(echo "$2" | sed "s/,/ /g"); do
    path=$(echo "$variable" | rev | cut -d"." -f2-  | rev)
    name=$(echo "$variable" | rev | cut -d"." -f1  | rev)
    [[ -n "$(jq -r "$path" < "$1" | jq -r 'keys[]' | grep -E "^$name")" ]] || return 1
  done

  return 0
}

# ==============================================================================
# Main

main
