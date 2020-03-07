#!/bin/sh

set -eu

apply() {
    local arch="$1"
    case "${arch}" in
        "arm32v6" | "arm32v7")
            patch -p0 < /patches/v8-missing-elf-arm32v6-7.patch
            ;;
        *)
            ;;
    esac
}

apply "$@"
