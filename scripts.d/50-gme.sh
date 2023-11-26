#!/bin/bash

GME_REPO="https://github.com/libgme/game-music-emu.git"
GME_COMMIT="6880d46552919f95604c87e5df14c13216927418"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$GME_REPO" "$GME_COMMIT" gme
    cd gme

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_DISABLE_FIND_PACKAGE_SDL2=TRUE \
        -DBUILD_SHARED_LIBS=OFF \
        -DENABLE_UBSAN=OFF \
        -DGME_UNRAR=OFF \
        -GNinja \
        ..
    ninja -j"$(nproc)"
    ninja install
}

ffbuild_configure() {
    echo --enable-libgme
}

ffbuild_unconfigure() {
    echo --disable-libgme
}
