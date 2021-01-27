#! /usr/bin/env bash
#
# Copyright (C) 2013-2014 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script is based on projects below
# https://github.com/yixia/FFmpeg-Android
# http://git.videolan.org/?p=vlc-ports/android.git;a=summary

#----------
FF_TARGET=$1
#can be debug
FF_TARGET_EXTRA=$2
set -e
set +x

FF_ALL_ARCHS="armv7a arm64 x86_64"

echo_usage() {
    echo "Usage:"
    echo "  compile-ffmpeg.sh armv7a|arm64|x86_64"
    echo "  compile-ffmpeg.sh all"
    echo "  compile-ffmpeg.sh clean"
    echo "  compile-ffmpeg.sh check"
    exit 1
}

#----------
case "$FF_TARGET" in
    "")
        echo "build default(armv7a)"
        sh tools/do-compile-ffmpeg.sh armv7a
    ;;
    armv7a|arm64|x86_64)
        echo "build $FF_TARGET"
        sh tools/do-compile-ffmpeg.sh $FF_TARGET $FF_TARGET_EXTRA
    ;;
    all)
        echo "build all"
        for ARCH in $FF_ALL_ARCHS
        do
            sh tools/do-compile-ffmpeg.sh $ARCH $FF_TARGET_EXTRA
        done
    ;;
    clean)
        for ARCH in $FF_ALL_ARCHS
        do
            if [ -d ffmpeg-$ARCH ]; then
                echo "ffmpeg-$ARCH"
                cd ffmpeg-$ARCH && git clean -xdf && cd -
            fi
        done
        rm -rf ./build/ffmpeg-*
    ;;
    *)
        echo_usage
        exit 1
    ;;
esac
