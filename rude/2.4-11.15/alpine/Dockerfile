FROM 'alpine:3.13.1'

#
# Ruby, build from source - based on https://hub.docker.com/_/ruby
#

ARG RUBY_MAJOR="2.4"
ARG RUBY_MINOR="2.4.10"
ARG RUBY_CHECKSUM="d5668ed11544db034f70aec37d11e157538d639ed0d0a968e2f587191fc530df"

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
# Node, download pre-built binary - based on https://hub.docker.com/_/node
#

ARG NODE_VERSION="11.15.0"
ARG NODE_CHECKSUM_X64="b9cb5c78318ac3a0c88ff0fbccffc376a9d73d874bcfec9fa092a99c80afd8cc"

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
