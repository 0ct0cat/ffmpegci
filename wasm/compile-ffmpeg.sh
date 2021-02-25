#! /usr/bin/env bash

set -e
set +x

ROOT=`pwd`
EMSDK_HOME=$ROOT/tools/emsdk
EM_CONFIG=$EMSDK_HOME/.emscripten
EM_CACHE=$EMSDK_HOME/upstream/emscripten/cache
EMSDK_NODE=$EMSDK_HOME/node/14.15.5_64bit/bin/node

export PATH=$PATH:$EMSDK_HOME:$EMSDK_HOME/upstream/emscripten:$EMSDK_HOME/node/14.15.5_64bit/bin

mkdir -p build

# Flags for code optimization, focus on speed instead
# of size
OPTIM_FLAGS=(
  -O3
)

# Convert array to string
OPTIM_FLAGS="${OPTIM_FLAGS[@]}"

CFLAGS="-s USE_PTHREADS=1 $OPTIM_FLAGS"
FFMPEG_CONFIG_FLAGS=(
  --target-os=none        # use none to prevent any os specific configurations
  --arch=x86_32           # use x86_32 to achieve minimal architectural optimization
  --enable-cross-compile  # enable cross compile
  --disable-x86asm        # disable x86 asm
  --disable-inline-asm    # disable inline asm
  --disable-stripping     # disable stripping
  --disable-programs      # disable programs build (incl. ffplay, ffprobe & ffmpeg)
  --disable-doc           # disable doc
  --disable-debug         # disable debug info, required by closure
  --disable-runtime-cpudetect   # disable runtime cpu detect
  --disable-autodetect    # disable external libraries auto detect
  --extra-cflags="$CFLAGS"
  --extra-cxxflags="$CFLAGS"
  --pkg-config-flags="--static"
  --enable-gpl            # required by x264
  --enable-nonfree        # required by fdk-aac
  --prefix=../build
  --ar=emar
  --ranlib=emranlib
  --cc=emcc
  --cxx=em++
  --objcc=emcc
  --dep-cc=emcc
)

WASM_FLAGS=(
  -I. -I./fftools
  -L../build/lib
  -Wno-deprecated-declarations -Wno-pointer-sign -Wno-implicit-int-float-conversion -Wno-switch -Wno-parentheses -Qunused-arguments
  -lavdevice -lavfilter -lavformat -lavcodec -lswresample -lswscale -lavutil -lpostproc -lm -pthread
  fftools/ffmpeg_opt.c fftools/ffmpeg_filter.c fftools/ffmpeg_hw.c fftools/cmdutils.c fftools/ffmpeg.c
  -o ../build/ffmpeg-core.js
  -s USE_SDL=2                                  # use SDL2
  -s USE_PTHREADS=1                             # enable pthreads support
  -s PROXY_TO_PTHREAD=1                         # detach main() from browser/UI main thread
  -s INVOKE_RUN=0                               # not to run the main() in the beginning
  -s EXIT_RUNTIME=1                             # exit runtime after execution
  -s MODULARIZE=1                               # use modularized version to be more flexible
  -s EXPORT_NAME="createFFmpegCore"             # assign export name for browser
  -s EXPORTED_FUNCTIONS="[_main]"  # export main and proxy_main funcs
  -s EXTRA_EXPORTED_RUNTIME_METHODS="[FS, cwrap, ccall, setValue, writeAsciiToMemory]"   # export preamble funcs
  -s INITIAL_MEMORY=2146435072                  # 64 KB * 1024 * 16 * 2047 = 2146435072 bytes ~= 2 GB
  $OPTIM_FLAGS
)

function echo_usage() {
    echo "Usage:"
    echo "  compile-ffmpeg.sh"
    echo "  compile-ffmpeg.sh clean"
    exit 1
}

function build_ffmpeg() {
    cd ffmpeg-wasm

    if [ ! -f ./ffbuild/config.log ]; then
        echo "1.build native to wasm"
        echo "FFMPEG_CONFIG_FLAGS=${FFMPEG_CONFIG_FLAGS[@]}"
        emconfigure ./configure "${FFMPEG_CONFIG_FLAGS[@]}"

        emmake make -j4

        emmake make install
    fi

    echo "2.build wasm to js"
    echo "WASM_FLAGS=${WASM_FLAGS[@]}"
    emcc "${WASM_FLAGS[@]}"

    cd -
}

#----------
case "$1" in
    "")
        echo "build ffmpeg wasm"
        build_ffmpeg
    ;;
    clean)
        if [ -d ffmpeg-wasm ]; then
            echo "clean ffmpeg-wasm"
            cd ffmpeg-wasm && git clean -xdf && cd -
            rm -rf build
        fi
    ;;
    *)
        echo_usage
        exit 1
    ;;
esac
