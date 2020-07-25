#!/bin/sh

set -eu

apply() {
    local arch="$1"
    local version="$2"
    case "${arch}" in
        "arm32v6" | "arm32v7")
            if [[ "$version" =~ ^13\.10\.[0-9]+$ ]]; then
                patch -p0 < /patches/v8-missing-elf-arm32v6-7.patch
            fi
            ;;
        *)
            ;;
    esac
}

apply "$@"
