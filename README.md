# ffmpegci
ci for android/ios and so on

base on ijk ffmpeg build

# Android
set ANDROID_NDK env

./init-android.sh

cd android

./compile-ffmpeg.sh all
