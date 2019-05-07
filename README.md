# Scratch Node.js Docker Images

Smallest Node.js Docker images.

## Content

* A fully statically linked and compressed Node.js binary
* An `/etc/passwd` entry for a `node` user

## Images

* `latest`, `12`, `12.1`, `12.1.0` – 16.5 MB
* `11`, `11.5`, `11.5.0` – 14.6 MB
* `10`, `10.13`, `10.13.0` – 14.3 MB
* `8`, `8.12`, `8.12.0` – 13.2 MB
* `6`, `6.14`, `6.14.4` – 11.6 MB

## Usage

```dockerfile
FROM node as builder

WORKDIR /app

COPY package.json package-lock.json index.js ./

RUN npm install --prod

FROM astefanutti/scratch-node

COPY --from=builder /app /

ENTRYPOINT ["./node", "index.js"]
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
$ docker cp scratch-node:node .
```
