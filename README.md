# Scratch Node.js Docker Images

Smallest, multi-architecture, Node.js binaries and Docker images (<10MB).

## Content

* A fully statically linked and compressed Node.js binary
* An `/etc/passwd` entry for a `node` user

## Images

* `latest`, `12`, `12.2`, `12.2.0` – 8.41 MB

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
