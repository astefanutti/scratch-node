# Distroless Node.js Docker Images

Multi-architecture distroless Node.js Docker images.

## Content

* The Node.js binary, statically linked using [_musl_](https://musl.libc.org), with opt-in support for i18n data
* The _musl_ dynamic linker, to support native modules
* A `/etc/passwd` entry for a `node` user

## Images

Multi-architecture images for `amd64`, `arm32v6`, `arm32v7` and `arm64v8`:

* `latest`, `16`, `16.9`, `16.9.0` – 17.1 MB / 43.5 MB
* `15`, `15.14`, `15.14.0` – 16.7 MB / 42.7 MB
* `14`, `14.17`, `14.17.0` – 15.9 MB / 41.7 MB
* `13`, `13.14`, `13.14.0` – 14.8 MB / 39.0 MB
* `12`, `12.22`, `12.22.1` – 15.2 MB / 39.8 MB
* `10`, `10.22`, `10.22.0` – 13.3 MB / 34.1 MB
* `8`, `8.17`, `8.17.0` – 11.2 MB / 30.1 MB

The image sizes are _compressed_ / _unpacked_.
They are published to the following repositories:
* [docker.io/astefanutti/scratch-node](https://hub.docker.com/r/astefanutti/scratch-node)
* [ghcr.io/astefanutti/scratch-node](https://github.com/users/astefanutti/packages/container/package/scratch-node)
* [quay.io/astefanutti/scratch-node](https://quay.io/repository/astefanutti/scratch-node)

## Usage

```dockerfile
FROM node as builder

WORKDIR /app

COPY package.json package-lock.json index.js ./

RUN npm install --prod

FROM astefanutti/scratch-node

COPY --from=builder /app /

ENTRYPOINT ["node", "index.js"]
```

### Native modules

Native modules need to be statically compiled with _musl_ to be loadable.
This can easily be achieved by updating the above example with:

```dockerfile
FROM node:alpine as builder

RUN apk update && apk add make g++ python

WORKDIR /app

COPY package.json package-lock.json index.js ./

RUN LDFLAGS='-static-libgcc -static-libstdc++' npm install --build-from-source=<native_module>

FROM astefanutti/scratch-node

COPY --from=builder /app /

ENTRYPOINT ["node", "index.js"]
```

### Internationalization

The Node binaries are link against the ICU library statically, and include a subset of ICU data (typically only the English locale) to keep the images size small.
Additional locale data can be provided if needed, so that the JS methods would work for all ICU locales. it can be made available to ICU by retrieving the locales data from the ICU sources, e.g.:

```dockerfile
FROM alpine as builder

RUN apk update && apk add curl

# Note the exact version of icu4c that's compatible depends on the Node version!
RUN curl -Lsq -o icu4c-69_1-src.zip https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.zip \
    && unzip -q icu4c-69_1-src.zip

FROM astefanutti/scratch-node:16.9.0

COPY --from=builder /icu/source/data/in/icudt69l.dat /icu/

ENV NODE_ICU_DATA=/icu
```

More information can be found in the [Providing ICU data at runtime](https://nodejs.org/api/intl.html#intl_providing_icu_data_at_runtime) from the Node.js documentation.

## Build

The image can be built by executing the following commands:

```console
$ git clone https://github.com/astefanutti/scratch-node
$ cd scratch-node
$ docker build --build-arg version=<nodejs_version> --build-arg arch=<target_architecture> .
```
