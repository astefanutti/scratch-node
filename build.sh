#!/bin/sh

set -eu

options() {
    local arch="$1"
    case "${arch}" in
        "x64" | "")
            echo ""
            ;;
        "arm32v7hf")
            echo "--dest-cpu=arm --cross-compiling --dest-os=linux --with-arm-float-abi=hard --with-arm-fpu=neon"
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
