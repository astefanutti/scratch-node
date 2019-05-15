# Scratch Node.js Docker Images

Smallest, multi-architecture, Node.js binaries and Docker images (<10MB).

## Content

* A fully statically linked and compressed Node.js binary
* An `/etc/passwd` entry for a `node` user

## Images

* `latest`, `12`, `12.2`, `12.2.0` – 8.41 MB

## Usage

#### Dockerfile

```dockerfile
FROM node as builder

WORKDIR /app

COPY package.json package-lock.json index.js ./

RUN npm install --prod

FROM astefanutti/scratch-node

COPY --from=builder /app /

ENTRYPOINT ["node", "index.js"]
```

#### Binary

```sh
# Linux / amd64
$ curl -Lo node https://github.com/astefanutti/scratch-node/releases/download/bin/node-12.2.0-amd64 && chmod +x node

# Linux / arm32v7
$ curl -Lo node https://github.com/astefanutti/scratch-node/releases/download/bin/node-12.2.0-arm32v7 && chmod +x node
```

The binaries for all the supported architectures can be found at [astefanutti/scratch-node/releases/tag/bin](https://github.com/astefanutti/scratch-node/releases/tag/bin).

## Build

The image can be built by executing the following commands:

```
$ git clone https://github.com/astefanutti/scratch-node
& cd scratch-node
$ docker build --build-arg version=<nodejs_version> --build-arg arch=<target_architecture> .
```

The Node.js binary can be extracted from the images, e.g.:

```
$ docker create --name scratch-node astefanutti/scratch-node
$ docker cp scratch-node:/bin/node .
```
