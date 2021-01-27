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

#--------------------
set -e

UNAME_S=$(uname -s)
UNAME_SM=$(uname -sm)
echo "build on $UNAME_SM"

echo "ANDROID_NDK=$ANDROID_NDK"

if [ -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK before starting."
    echo "They must point to your NDK directories."
    echo ""
    exit 1
fi

NDK_REL=$(grep -o '^Pkg\.Revision.*=[0-9]*.*' $ANDROID_NDK/source.properties 2>/dev/null | sed 's/[[:space:]]*//g' | cut -d "=" -f 2)
case "$NDK_REL" in
    21*)
        if test -d ${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin
        then
            export TOOLCHAIN_PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
            export SYSROOT_PATH=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot
            echo "ndk $NDK_REL detected"
        else
            echo "You need the ndk21"
            exit 1
        fi
    ;;
    *)
        echo "You need the ndk21 or later"
        exit 1
    ;;
esac

case "$UNAME_S" in
    Darwin)
        export MAKE_FLAG=-j`sysctl -n machdep.cpu.thread_count`
    ;;
    Linux)
        export MAKE_FLAG=-j4
    ;;
    WSL)
    ;;
    *)
        echo "pls build on linux or mac.can't build on $UNAME_S for the time being"
        echo "maybe try WSL ?"
    ;;
esac
