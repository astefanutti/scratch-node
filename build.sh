#!/bin/sh

set -eu

target() {
    local arch="$1"
    case "${arch}" in
        "x64" | "x86_64" | "amd64" | "")
            echo "x86_64-linux-musl"
            ;;
        "arm32v6")
            echo "armv6-linux-musleabihf"
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

ld_flags() {
    local arch="$1"
    case "${arch}" in
        "arm32v6")
            echo "-Wl,-Bstatic,-latomic,-rpath=/usr/local/armv6-linux-musleabihf/lib"
            ;;
        "arm32v7")
            echo "-Wl,-Bstatic,-latomic,-rpath=/usr/local/armv7-linux-musleabihf/lib"
            ;;
        "" | *)
            echo ""
            ;;
    esac
}

gcc_config() {
    local arch="$1"
    case "${arch}" in
        "arm32v6")
            echo "--with-arch=armv6zk+fp --with-tune=arm1176jzf-s"
            ;;
        "arm32v7")
            echo "--with-arch=armv7-a+neon-vfpv4 --with-tune=generic-armv7-a"
            ;;
        "" | *)
            echo ""
            ;;
    esac
}

config_mak() {
    local arch="$1"
    cat > $2 <<-EOF
    BINUTILS_VER=2.33.1
    GCC_VER=9.2.0
    TARGET=$(target ${BUILD_ARCH:-""})
    OUTPUT=/usr/local
    GCC_CONFIG=$(gcc_config $arch) --enable-languages=c,c++
    BINUTILS_CONFIG=--enable-ld --enable-gold=default --enable-linker-build-id --enable-lto
	EOF
}

node_config() {
    local arch="$1"
    case "${arch}" in
        "x64" | "x86_64" | "amd64")
            echo "--enable-lto"
            ;;
        "arm32v6")
            echo "--with-arm-float-abi=hard --with-arm-fpu=vfp"
            ;;
        "arm32v7")
            echo "--with-arm-float-abi=hard --with-arm-fpu=vfpv3"
            ;;
        "arm64v8")
            echo "--with-arm-float-abi=hard --with-arm-fpu=neon --enable-lto"
            ;;
        "" | *)
            echo ""
            ;;
    esac
}

call() {
    local func="$1"
    shift
    ${func} "$@"
}

call "$@"
