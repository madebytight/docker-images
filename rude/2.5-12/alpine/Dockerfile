FROM 'alpine:3.13.1'

#
# Ruby:
# - Builds from source
# - Based on https://hub.docker.com/_/ruby
#

ARG RUBY_MAJOR="2.5"
ARG RUBY_MINOR="2.5.9"
ARG RUBY_CHECKSUM="a87f2fa901408cc77652c1a55ff976695bbe54830ff240e370039eca14b358f0"

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

ARG NODE_VERSION="12.22.7"

RUN set -eux; \
    ARCH="$(apk --print-arch)"; \
    if [ $ARCH = "x86_64" ]; then \
      NODE_SRC="https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64-musl.tar.xz";\
      wget -O node.tar.xz "$NODE_SRC"; \
      echo "c8672a664087e96b4e2804caf77a0aaa8c1375ae6b378edb220a678155383a81 *node.tar.xz" | sha256sum -c; \
      tar -xJf "node.tar.xz" -C /usr/local --strip-components=1 --no-same-owner; \
      ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
      rm node.tar.xz; \
    else \
      # Install temporary and permanent dependencies
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
        python2 \
        python3 \
      ; \

      # Add gpg keys
      for key in \
        4ED778F539E3634C779C87C6D7062848A1AB005C \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        74F12602B6F1C4E913FAA37AD3A89613643B6201 \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
        108F52B48DB57BB0CC439B2997B01419BD92F80A \
        B9E2F5981AA6E0CD28160D9FF13993A75599653C \
      ; do \
        gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
      done; \

      # Download and verify source
      wget "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt"; \
      wget "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.sig"; \
      gpg --verify "SHASUMS256.txt.sig" "SHASUMS256.txt"; \
      wget "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz"; \
      grep node-v$NODE_VERSION.tar.xz SHASUMS256.txt | sha256sum -c -; \

      # Unpack and build
      mkdir -p /usr/src/node; \
      tar -xJf node-v$NODE_VERSION.tar.xz -C /usr/src/node --strip-components=1; \
      cd /usr/src/node; \
      ./configure; \
      make -j$(getconf _NPROCESSORS_ONLN) V=; \
      make install; \

      # Cleanup
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
