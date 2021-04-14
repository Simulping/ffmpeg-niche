#!/bin/bash

VMAF_REPO="https://github.com/Netflix/vmaf.git"
VMAF_COMMIT="771cec3c7366002d539aab9eb3f2278df224d537"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$VMAF_REPO" "$VMAF_COMMIT" vmaf
    cd vmaf

    mkdir build && cd build

    export CFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export CXXFLAGS="-static-libgcc -static-libstdc++ -I/opt/ffbuild/include -O2"
    export LDFLAGS="-static-libgcc -static-libstdc++ -L/opt/ffbuild/lib -O2"

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --buildtype=release
        --default-library=static
        -Denable_tests=false
        -Denable_docs=false
        -Denable_avx512=true
    )

    if [[ $TARGET == win* ]]; then
        myconf+=(
            --cross-file=/cross.meson
        )
    else
        echo "Unknown target"
        return -1
    fi

    meson "${myconf[@]}" ../libvmaf
    ninja -j"$(nproc)"
    ninja install

    sed -i 's/Libs.private.*/& -lstdc++/; t; $ a Libs.private: -lstdc++' "$FFBUILD_PREFIX"/lib/pkgconfig/libvmaf.pc
}

ffbuild_configure() {
    echo --enable-libvmaf
}

ffbuild_unconfigure() {
    echo --disable-libvmaf
}
