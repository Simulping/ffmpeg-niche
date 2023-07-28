#!/bin/bash

MINGW_REPO="https://github.com/mingw-w64/mingw-w64.git"
MINGW_COMMIT="868b4a0773c5d09685635785dacad00a6dbae9f3"

ffbuild_enabled() {
    [[ $TARGET =~ ^(ucrt64|win(64|32))$ ]] || return -1
    return 0
}

ffbuild_dockerlayer() {
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /"
    to_df "COPY --from=${SELFLAYER} /opt/mingw/. /opt/mingw"
}

ffbuild_dockerfinal() {
    to_df "COPY --from=${PREVLAYER} /opt/mingw/. /"
}

ffbuild_dockerbuild() {
    git-mini-clone "$MINGW_REPO" "$MINGW_COMMIT" mingw
    cd mingw

    cd mingw-w64-headers

    unset CFLAGS CXXFLAGS LDFLAGS PKG_CONFIG_LIBDIR

    SYSROOT="$($CC -print-sysroot)"

    local myconf=(
        --host="$FFBUILD_TOOLCHAIN"
        --enable-idl
    )

    if [[ $TARGET == ucrt64 ]]; then
        myconf+=(
            --prefix="$SYSROOT/mingw"
        )
    else
        myconf+=(
            --prefix="/usr/$FFBUILD_TOOLCHAIN"
            --with-default-msvcrt=msvcrt
        )
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="/opt/mingw"

    cd ../mingw-w64-libraries/winpthreads

    local myconf=(
        --host="$FFBUILD_TOOLCHAIN"
        --with-pic
        --disable-shared
        --enable-static
    )

    if [[ $TARGET == ucrt64 ]]; then
        myconf+=(
            --prefix="$SYSROOT/mingw"
        )
    else
        myconf+=(
            --prefix="/usr/$FFBUILD_TOOLCHAIN"
        )
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="/opt/mingw"
}

ffbuild_configure() {
    echo --disable-w32threads --enable-pthreads
}
