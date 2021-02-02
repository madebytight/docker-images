FROM 'alpine:3.13.1'

#
# Ruby, build from source - based on https://hub.docker.com/_/ruby
#

ARG RUBY_MAJOR="2.7"
ARG RUBY_MINOR="2.7.2"
ARG RUBY_CHECKSUM="1b95ab193cc8f5b5e59d2686cb3d5dcf1ddf2a86cb6950e0b4bdaae5040ec0d6"

ARG RUBY_SRC="https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_MINOR}.tar.xz"
ARG RUBY_DST="ruby-${RUBY_MINOR}"

RUN apk add --no-cache \
      gmp-dev

# Disable gem documentation
RUN set -eux; \
    mkdir -p /usr/local/etc; \
    { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc

# Download & build
RUN set -eux; \
    apk add --no-cache --virtual .ruby-deps \
      autoconf \
      bison \
      bzip2 \
      bzip2-dev \
      ca-certificates \
      coreutils \
      dpkg-dev dpkg \
      gcc \
      gdbm-dev \
      glib-dev \
      libc-dev \
      libffi-dev \
      libxml2-dev \
      libxslt-dev \
      linux-headers \
      make \
      ncurses-dev \
      openssl \
      openssl-dev \
      patch \
      procps \
      readline-dev \
      ruby \
      tar \
      xz \
      yaml-dev \
      zlib-dev \
    ; \

    # Download and unpack source
    wget -O ruby.tar.xz $RUBY_SRC; \
    echo "$RUBY_CHECKSUM *ruby.tar.xz" | sha256sum -c; \
    mkdir -p /usr/src/ruby; \
    tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
    rm ruby.tar.xz; \

    # Build
    cd /usr/src/ruby; \
    export ac_cv_func_isnan=yes ac_cv_func_isinf=yes; \
    ./configure \
      --build=$(dpkg-architecture --query DEB_BUILD_GNU_TYPE) \
      --disable-install-doc \
      --enable-shared; \
    make -j $(nproc); \
    make install; \

    # Cleanup
    cd /; \
    rm -r /usr/src/ruby; \
    apk del --no-network .ruby-deps

#
# Node, download prebuilt binary - based on https://hub.docker.com/_/node
#

ARG NODE_VERSION="10.23.2"
ARG NODE_CHECKSUM_X64="b3ae42c904bfda144df81275fbc8ef89baab0babca0f95a1e06f4b4064f3f8ee"

RUN set -eux; \
    ARCH="$(apk --print-arch)"; \
    CHECKSUM=""; \
    if [ $ARCH = "x86_64" ]; then \
      ARCH="x64"; \
      CHECKSUM="$NODE_CHECKSUM_X64"; \
    fi; \
    NODE_SRC="https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz";\
    wget -O node.tar.xz "$NODE_SRC"; \
    echo "$CHECKSUM *node.tar.xz" | sha256sum -c; \
    tar -xJf "node.tar.xz" -C /usr/local --strip-components=1 --no-same-owner; \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
    rm node.tar.xz

#
# Defaults for both ruby and node
#

# Common dependencies
RUN set -eux; \
    apk add \
      build-base \
      bzip2 \
      ca-certificates \
      gcc \
      libc-dev \
      libffi-dev \
      make \
      postgresql-dev \
      procps \
      yaml-dev \
      zlib-dev \
    ;

# Install bundler
RUN gem install bundler

# Install yarn
RUN npm install -g yarn

# Verify installation
RUN set -eux; \
    ruby -v; \
    gem -v; \
    bundler -v; \
    node -v; \
    npm -v; \
    yarn -v


CMD ["sh"]
