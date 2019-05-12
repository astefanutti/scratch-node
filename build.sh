#!/bin/sh

set -eu

target() {
    local arch="$1"
    case "${arch}" in
        "x64" | "x86_64" | "amd64" | "")
            echo "x86_64-linux-musl"
            ;;
        "arm32v7")
            echo "armv7-linux-musleabihf"
            ;;
        "arm64v8")
            echo "aarch64-linux-musl"
            ;;
        *)
            >&2 echo Unsupported architecture: "${arch}"
            exit 1
            ;;
    esac
}

config() {
    local arch="$1"
    case "${arch}" in
        "x64" | "x86_64" | "amd64" | "")
            echo ""
            ;;
        "arm32v7" | "arm64v8")
            echo "--with-arm-float-abi=hard --with-arm-fpu=neon"
            ;;
        *)
            >&2 echo Unsupported architecture: "${arch}"
            exit 1
            ;;
    esac
}

call() {
    local func="$1"
    shift
    ${func} "$@"
}

call "$@"
