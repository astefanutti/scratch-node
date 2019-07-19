# Scratch Node.js Docker Images

Smallest Node.js Docker images.

## Content

* A statically linked Node.js binary
* The _musl_ dynamic linker to support native modules
* A `/etc/passwd` entry for a `node` user

## Images

Multi-architecture images for `amd64`, `arm32v6`, `arm32v7` and `arm64v8`:

* `latest`, `12`, `12.6`, `12.6.0` – 14 MB / 34.5 MB
* `10`, `10.16`, `10.16.0` – 11 MB / 29.1 MB
* `8`, `8.16`, `8.16.0` – 10 MB / 25.2 MB

The image sizes are - _compressed_ / _unpacked_.

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

Note that native modules need to be statically compiled with _musl_ to be loadable.
This can easily be achieved by updating the above example with:

```dockerfile
FROM node:alpine as builder

RUN apk update && apk add make g++ python

...

RUN LDFLAGS='-static-libgcc -static-libstdc++' npm install --build-from-source=<native_module>

FROM astefanutti/scratch-node

...
```

## Build

The image can be built by executing the following commands:

```
$ git clone https://github.com/astefanutti/scratch-node
& cd scratch-node
$ docker build --build-arg version=<nodejs_version> --build-arg arch=<target_architecture> .
```
