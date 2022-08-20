#!/bin/bash

LIBSSH_REPO="https://git.libssh.org/projects/libssh.git"
LIBSSH_COMMIT="ac6d2fad4a8bf07277127736367e90387646363f"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$LIBSSH_REPO" "$LIBSSH_COMMIT" libssh
    cd libssh

    mkdir build && cd build

    cmake \
        -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DBUILD_SHARED_LIBS=OFF \
        -DWITH_{BLOWFISH_CIPHER,DSA,PCAP,SFTP,ZLIB}=ON \
        -DWITH_{EXAMPLES,SERVER}=OFF \
        -GNinja \
        ..
    ninja -j$(nproc)
    ninja install

    {
        echo "Requires.private: libssl libcrypto zlib"
        echo "Cflags.private: -DLIBSSH_STATIC" 
    } >> "$FFBUILD_PREFIX"/lib/pkgconfig/libssh.pc
}

ffbuild_configure() {
    echo --enable-libssh
}

ffbuild_unconfigure() {
    echo --disable-libssh
}

ffbuild_ldflags() {
    echo -Wl,--allow-multiple-definition
}
