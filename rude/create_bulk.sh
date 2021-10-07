#!/usr/bin/env bash

RUBY_VERSIONS=(
  "2.5.9 a87f2fa901408cc77652c1a55ff976695bbe54830ff240e370039eca14b358f0"
  "2.6.8 8262e4663169c85787fdc9bfbd04d9eb86eb2a4b56d7f98373a8fcaa18e593eb"
  "2.7.4 2a80824e0ad6100826b69b9890bf55cfc4cf2b61a1e1330fccbcb30c46cef8d7"
  "3.0.2 570e7773100f625599575f363831166d91d49a1ab97d3ab6495af44774155c40"
)

NODE_VERSIONS=(
  "12.22.6 0ce2b97ecbbd84f1a5ed13278ed6845d93c6454d8550730b247a990438dba322"
  "14.18.0 3f6bdb98f5734e10bd190635b8688347c5ac794091a1f11cb1c7694b43a969b7"
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
