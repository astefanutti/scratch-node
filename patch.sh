#!/bin/sh

set -eu

apply() {
    local arch="$1"
    local version="$2"

    case "${version}" in
        13.10.*)
            if [[ "$arch" = "arm32v6" ]] || [[ "$arch" = "arm32v7" ]]; then
                patch -p0 < /patches/v8-missing-elf-arm32v6-7.patch
            fi
            ;;
        15.*.* | 16.*.* | 17.*.* | 18.*.*)
            patch -p0 < /patches/v8-cppgc-shared-no-lto.patch
            ;;
        *)
            ;;
    esac
}

apply "$@"
