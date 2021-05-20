#!/usr/bin/env bash

function confirm() {
  while true; do
    read -p "$1 [y/n]: " answer
    case $answer in
      [Yy]*) echo true; return 0;;
      [Nn]*) echo false; return 0;;
    esac
  done
}

set -e

if [ -z ${RUBY_VERSION} ]; then read -p 'Ruby version: ' RUBY_VERSION; fi
if [ -z ${RUBY_CHECKSUM} ]; then read -p 'Ruby checksum: ' RUBY_CHECKSUM; fi
if [ -z ${NODE_VERSION} ]; then read -p 'Node version: ' NODE_VERSION; fi
if [ -z ${NODE_CHECKSUM_X64} ]; then read -p 'Node checksum(x64) ' NODE_CHECKSUM_X64; fi

REPOSITORY="madebytight/rude"

RUBY_MAJOR=`echo $RUBY_VERSION | grep -o "[0-9]*.[0-9]*" | head -1`
NODE_MAJOR=`echo $NODE_VERSION | grep -o "[0-9]*" | head -1`
NODE_MINOR=`echo $NODE_VERSION | grep -o "[0-9]*.[0-9]*" | head -1`

DOCKERFILE_FOLDER="$RUBY_MAJOR-$NODE_MAJOR/alpine"
TEMPLATE="./.template/alpine.Dockerfile"

mkdir -p $DOCKERFILE_FOLDER
sed -r \
    -e 's!%%RUBY_MAJOR%%!'"$RUBY_MAJOR"'!g' \
    -e 's!%%RUBY_MINOR%%!'"$RUBY_VERSION"'!g' \
    -e 's!%%RUBY_CHECKSUM%%!'"$RUBY_CHECKSUM"'!g' \
    -e 's!%%NODE_VERSION%%!'"$NODE_VERSION"'!g' \
    -e 's!%%NODE_CHECKSUM_X64%%!'"$NODE_CHECKSUM_X64"'!g' \
    "$TEMPLATE" > "$DOCKERFILE_FOLDER/Dockerfile"

PINNED_TAG="$REPOSITORY:$RUBY_VERSION-$NODE_VERSION-alpine"
EPHEMERAL_TAGS=("$REPOSITORY:$RUBY_MAJOR-$NODE_MAJOR-alpine" "$REPOSITORY:$RUBY_MAJOR-$NODE_MINOR-alpine")

docker build \
  -t "$PINNED_TAG" \
  "$DOCKERFILE_FOLDER"

# docker push $PINNED_TAG

# for tag in "${EPHEMERAL_TAGS[@]}"; do
#   echo
#   echo

#   if [ -z ${ALL_TAGS} ]; then
#     choice=$(confirm "Apply and push $tag?")
#   else
#     choice=true
#   fi

#   if $choice; then
#     docker image tag $PINNED_TAG $tag
#     docker push $tag
#   fi
# done
