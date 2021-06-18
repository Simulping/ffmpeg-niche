#!/bin/bash

SERD_REPO="https://github.com/drobilla/serd.git"
SERD_COMMIT="10c6dcff8d28ca2a05d2ebcfa9bb47e24e5a9d64"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SERD_REPO" "$SERD_COMMIT" serd
    cd serd
    git submodule update --init --recursive --depth 1

    local mywaf=(
        --prefix="$FFBUILD_PREFIX"
        --static
        --largefile
        --stack-check
        --no-{shared,utils}
    )

    CC="${FFBUILD_CROSS_PREFIX}gcc" CXX="${FFBUILD_CROSS_PREFIX}g++" ./waf configure "${mywaf[@]}"
    ./waf -j$(nproc)
    ./waf install

    sed -i 's/Cflags:/Cflags: -DSERD_STATIC/' "$FFBUILD_PREFIX"/lib/pkgconfig/serd-0.pc
}
