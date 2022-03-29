#!/bin/bash -ex

# Python
make dependency-list IMAGE=python:3.10.4-bullseye
make dependency-list IMAGE=python:3.10.4-slim-bullseye
make dependency-list IMAGE=python:3.10.4-alpine
make dependency-list IMAGE=amazon/aws-lambda-python:3.6.2022.03.23.17
make dependency-list IMAGE=makeops/dependency-list/python-app:example
