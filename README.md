# ffmpegci
ci for android/ios/wasm and so on

base on ijk ffmpeg build

# Android
set ANDROID_NDK env

./init-android.sh

cd android

./compile-ffmpeg.sh all

# wasm

./init-wams.sh

cd wasm

./compile-ffmpeg.sh
