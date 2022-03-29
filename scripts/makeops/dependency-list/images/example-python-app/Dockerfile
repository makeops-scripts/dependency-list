FROM python:3.10.4-alpine

COPY assets/ /
RUN \
    pip install -r /application/requirements.txt

ENV \
    BUILD_ID=0 \
    BUILD_DATE="2022-03-27T18:31:33+0000" \
    BUILD_REPO="https://github.com/makeops-scripts/dependency-list.git" \
    BUILD_BRANCH="main" \
    BUILD_COMMIT_HASH="49569ec" \
    BUILD_COMMIT_DATE="2022-03-27T18:31:33+0000" \
    PROJECT_GROUP="makeops" \
    PROJECT_NAME="dependency-list" \
    PROJECT_ID="mo-dl" \
    PROJECT_DISPLAY_NAME="MakeOps Scripts - Dependency List Utility" \
    PROJECT_TAG="makeops"
