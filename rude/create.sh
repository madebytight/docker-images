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

if [ -z ${BASE_IMAGE} ]; then read -p 'Base imge: ' BASE_IMAGE; fi
if [ -z ${RUBY_VERSION} ]; then read -p 'Ruby version: ' RUBY_VERSION; fi
if [ -z ${RUBY_CHECKSUM} ]; then read -p 'Ruby checksum: ' RUBY_CHECKSUM; fi
if [ -z ${NODE_VERSION} ]; then read -p 'Node version: ' NODE_VERSION; fi
if [ -z ${NODE_CHECKSUM} ]; then read -p 'Node checksum ' NODE_CHECKSUM; fi

REPOSITORY="madebytight/rude"

RUBY_MAJOR=`echo $RUBY_VERSION | grep -o "[0-9]*.[0-9]*" | head -1`
NODE_MAJOR=`echo $NODE_VERSION | grep -o "[0-9]*" | head -1`
NODE_MINOR=`echo $NODE_VERSION | grep -o "[0-9]*.[0-9]*" | head -1`

DOCKERFILE_FOLDER="$RUBY_MAJOR-$NODE_MAJOR/`echo $BASE_IMAGE | sed -e 's/[^a-z]//g'`"
TEMPLATE="./.template/`echo $BASE_IMAGE | sed -e 's/[^a-z]//g'`.Dockerfile"

BUILDER_NAME="madebytight-rude"
PLATFORMS="linux/amd64,linux/arm64"

echo "-> Create Dockerfile"
mkdir -p $DOCKERFILE_FOLDER
sed -r \
    -e 's!%%BASE_IMAGE%%!'"$BASE_IMAGE"'!g' \
    -e 's!%%RUBY_MAJOR%%!'"$RUBY_MAJOR"'!g' \
    -e 's!%%RUBY_MINOR%%!'"$RUBY_VERSION"'!g' \
    -e 's!%%RUBY_CHECKSUM%%!'"$RUBY_CHECKSUM"'!g' \
    -e 's!%%NODE_VERSION%%!'"$NODE_VERSION"'!g' \
    -e 's!%%NODE_CHECKSUM%%!'"$NODE_CHECKSUM"'!g' \
    "$TEMPLATE" > "$DOCKERFILE_FOLDER/Dockerfile"

echo "-> Prepare tags"
PINNED_BASE=`echo $BASE_IMAGE | sed 's/://g'`
PINNED_TAG="$REPOSITORY:$RUBY_VERSION-$NODE_VERSION-$PINNED_BASE"
EPHEMERAL_BASES=(
  "`echo $BASE_IMAGE | sed 's/://g' | sed -e 's/\.[0-9]*$//g'`"
  "`echo $BASE_IMAGE | sed 's/://g' | sed -e 's/[0-9]*\.[0-9]*//g'`"
)

EPHEMERAL_TAGS=()
for base in "${EPHEMERAL_BASES[@]}"; do
  for ruby in $RUBY_VERSION $RUBY_MAJOR; do
    for node in $NODE_VERSION $NODE_MINOR $NODE_MAJOR; do
      EPHEMERAL_TAGS+=("$REPOSITORY:$ruby-$node-$base")
    done
  done
done

TAG_ARGS="-t $PINNED_TAG"
for tag in "${EPHEMERAL_TAGS[@]}"; do
  if [ "$ALL_TAGS" = true ]; then
    choice=true
  else
    choice=$(confirm "   Apply $tag?")
  fi

  if $choice; then
    TAG_ARGS="$TAG_ARGS -t $tag"
  fi
done

if ! docker buildx inspect --bootstrap $BUILDER_NAME 2>/dev/null 1>&2; then
  echo "-> Create buildx instance"
  docker buildx create --name $BUILDER_NAME > /dev/null
else
  echo "-> buildx instance exists"
fi

# Make sure the buildx instance is ready
echo "-> Start buildx instance"
docker buildx inspect --bootstrap $BUILDER_NAME 2>/dev/null 1>&2

echo "-> Switch buildx instance"
docker buildx use $BUILDER_NAME

echo "-> Build image"
docker buildx build \
  --platform $PLATFORMS \
  $TAG_ARGS \
  --push \
  $DOCKERFILE_FOLDER
