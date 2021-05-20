FROM 'alpine:3.13.1'

#
# Ruby:
# - Builds from source
# - Based on https://hub.docker.com/_/ruby
#

ARG RUBY_MAJOR="%%RUBY_MAJOR%%"
ARG RUBY_MINOR="%%RUBY_MINOR%%"
ARG RUBY_CHECKSUM="%%RUBY_CHECKSUM%%"

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
    autoconf; \
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
# Node:
# - Uses pre-built binary for x86_64, otherwise builds from source
# - Based on https://hub.docker.com/_/node
#

ARG NODE_VERSION="%%NODE_VERSION%%"

RUN set -eux; \
    ARCH="$(apk --print-arch)"; \
    CHECKSUM=""; \
    if [ $ARCH = "x86_64" ]; then \
      NODE_SRC="https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64-musl.tar.xz";\
      wget -O node.tar.xz "$NODE_SRC"; \
      echo "%%NODE_CHECKSUM_X64%% *node.tar.xz" | sha256sum -c; \
      tar -xJf "node.tar.xz" -C /usr/local --strip-components=1 --no-same-owner; \
      ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
      rm node.tar.xz; \
    else \
      apk add --no-cache \
        libstdc++ \
      ; \
      apk add --no-cache --virtual .node-build-deps \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
      ; \
      wget "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz"; \
      mkdir -p /usr/src/node; \
      tar -xJf node-v$NODE_VERSION.tar.xz -C /usr/src/node --strip-components=1; \
      cd /usr/src/node; \
      ./configure; \
      make -j$(getconf _NPROCESSORS_ONLN) V=; \
      make install; \
      cd /; \
      rm node-v$NODE_VERSION.tar.xz; \
      rm -rf /usr/src/node; \
      apk del .node-build-deps; \
    fi

#
# Runtime configuration
#

# Install libraries and binaries
RUN set -eux; \
    apk add --no-cache \
      build-base \
      bzip2 \
      ca-certificates \
      gcc \
      git \
      libc-dev \
      libffi-dev \
      make \
      postgresql-dev \
      procps \
      tzdata \
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

# Bundler setup
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$PATH
RUN mkdir -p "$GEM_HOME"

# Permissions
RUN chmod 777 "$GEM_HOME" && \
    mkdir /app && chmod 777 "/app"

# Create and switch to non root user
RUN addgroup -S app && \
    adduser -S app -G app
USER app

RUN bundle config set --global without 'development test'; \
    bundle config set --global jobs $(nproc)

WORKDIR /app
