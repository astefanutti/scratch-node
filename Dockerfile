FROM alpine:3.9.4 as builder

RUN apk update
RUN apk add make g++ python gnupg curl file

ARG arch=
ENV BUILD_ARCH=$arch

COPY build.sh /

RUN curl -Lsq -o musl-cross-make.zip https://github.com/richfelker/musl-cross-make/archive/v0.9.8.zip \
    && unzip -q musl-cross-make.zip \
    && mv musl-cross-make-0.9.8 musl-cross-make \
    && $(/build.sh config_mak ${BUILD_ARCH:-""} /musl-cross-make/config.mak) \
    && cd /musl-cross-make \
    && make install -j$(getconf _NPROCESSORS_ONLN) V= \
    && rm -rf /musl-cross-make

ARG version=0.0.0
ENV NODE_VERSION=$version

# gpg keys listed at https://github.com/nodejs/node#release-keys
RUN for key in \
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
      FD3A5288F042B6850C66B31F09FE44734EB7990E \
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      77984A986EBC2AA786BC0F66B01FBB92821C587A \
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
      4ED778F539E3634C779C87C6D7062848A1AB005C \
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
      B9E2F5981AA6E0CD28160D9FF13993A75599653C \
    ; do \
      gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
      gpg --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
      gpg --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c -

RUN tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && export TARGET=$(/build.sh target ${BUILD_ARCH:-""}) \
    && export CC=$TARGET-gcc \
    && export CXX=$TARGET-g++ \
    && export CXXFLAGS="-Os -ffunction-sections -fdata-sections" \
    && export LDFLAGS="-Wl,--gc-sections,--strip-all" \
    && EXTRA_CONFIG=$(/build.sh node_config ${BUILD_ARCH:-""}) \
    && ln -snf libc.so /usr/local/$TARGET/lib/ld-musl-*.so.1 \
    && ln -snf /usr/local/$TARGET/lib/ld-musl-*.so.1 /lib \
    && ./configure \
        --partly-static \
        --without-dtrace \
        --without-inspector \
        --without-etw \
        ${EXTRA_CONFIG} \
    && make -j$(getconf _NPROCESSORS_ONLN) V=

RUN echo 'node:x:1000:1000:Linux User,,,:/home/node:/bin/sh' > /tmp/passwd

FROM scratch

ARG version=0.0.0

COPY --from=builder node-v$version/out/Release/node /bin/node
COPY --from=builder /lib/ld-musl-*.so.1 /lib/
COPY --from=builder /tmp/passwd /etc/passwd

USER node

ENTRYPOINT ["node"]
