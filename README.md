# Scratch Node.js Docker Images

Smallest Node.js Docker images (<12MB).

## Content

* A statically linked and compressed Node.js binary
* The _musl_ dynamic linker to support native modules
* An `/etc/passwd` entry for a `node` user

## Images

Multi-architecture images for the `amd64`, `arm32v6`, `arm32v7` and `arm64v8` architectures:

* `latest`, `12`, `12.2`, `12.2.0` – 12 MB

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
