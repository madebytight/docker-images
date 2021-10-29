#!/usr/bin/env bash

RUBY_VERSIONS=(
  "2.5.9 a87f2fa901408cc77652c1a55ff976695bbe54830ff240e370039eca14b358f0"
  "2.6.8 8262e4663169c85787fdc9bfbd04d9eb86eb2a4b56d7f98373a8fcaa18e593eb"
  "2.7.4 2a80824e0ad6100826b69b9890bf55cfc4cf2b61a1e1330fccbcb30c46cef8d7"
  "3.0.2 570e7773100f625599575f363831166d91d49a1ab97d3ab6495af44774155c40"
)

NODE_VERSIONS=(
  "12.22.7 c8672a664087e96b4e2804caf77a0aaa8c1375ae6b378edb220a678155383a81"
  "14.18.1 8d6d2b71b76dc31bbcf12827b9e60212bc04a556c3498e75708d38f5eb4ae6eb"
  "16.9.1 528061413f47f9cd87feb43941a74768cabcbb7a35395b3680a4b89efa1f7573"
)

for RUBY in "${RUBY_VERSIONS[@]}"; do
  RUBY_VERSION=`echo $RUBY | tr " " "\n" | head -1`
  RUBY_CHECKSUM=`echo $RUBY | tr " " "\n" | tail -1`


  for NODE in "${NODE_VERSIONS[@]}"; do
    NODE_VERSION=`echo $NODE | tr " " "\n" | head -1`
    NODE_CHECKSUM=`echo $NODE | tr " " "\n" | tail -1`

    echo "Ruby: $RUBY_VERSION"
    echo "Node: $NODE_VERSION"
    echo ""
    echo ""
    echo ""

    RUBY_VERSION=$RUBY_VERSION \
      RUBY_CHECKSUM=$RUBY_CHECKSUM \
      NODE_VERSION=$NODE_VERSION \
      NODE_CHECKSUM=$NODE_CHECKSUM \
      ALL_TAGS=true \
      ./create.sh

    echo ""
    echo ""
    echo ""
  done
done
