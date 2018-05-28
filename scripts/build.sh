#!/bin/bash

set -xe

cat <<EOF
============================================
Building Demo ...
============================================
EOF


if [[ $OSENV == 'macosx' ]]; then
    mkdir -p $TRAVIS_BUILD_DIR/test/build_macosx && cd $TRAVIS_BUILD_DIR/test/build_macosx
    cmake ..
    make "-j$(sysctl -n hw.ncpu)"
    ctest --output-on-failure "-j$(sysctl -n hw.ncpu)" 
elif [[ $OSENV == 'linux' ]]; then
    mkdir -p $TRAVIS_BUILD_DIR/test/build_linux && cd $TRAVIS_BUILD_DIR/test/build_linux
    cmake ..
    make -j `nproc`
    ctest --output-on-failure -j `nproc`
elif [[ $OSENV == 'android' ]]; then
    TMP_DIR=$HOME/build_android_tmp
    mkdir -p $TMP_DIR && cd $TMP_DIR

    # Download and decompress Android ndk 
    wget -c https://dl.google.com/android/repository/android-ndk-r14b-darwin-x86_64.zip
    unzip -q android-ndk-r14b-darwin-x86_64.zip
    ANDROID_STANDALONE_TOOLCHAIN=`pwd`/android-toolchain-gcc
    android-ndk-r14b/build/tools/make-standalone-toolchain.sh --force --arch=arm --platform=android-21 --install-dir=$ANDROID_STANDALONE_TOOLCHAIN

    # Create the build directory for CMake.
    mkdir -p $TRAVIS_BUILD_DIR/test/build_android && cd $TRAVIS_BUILD_DIR/test/build_android

    cmake -DCMAKE_TOOLCHAIN_FILE=$TRAVIS_BUILD_DIR/test/bazel.cmake/third-party/android-cmake/android.toolchain.cmake \
          -DANDROID_STANDALONE_TOOLCHAIN=$ANDROID_STANDALONE_TOOLCHAIN \
          -DANDROID_ABI="armeabi-v7a with NEON FP16" \
          -DANDROID_NATIVE_API_LEVEL=21 \
          ..
    make "-j$(sysctl -n hw.ncpu)"
else # IOS
    mkdir -p $TRAVIS_BUILD_DIR/test/build_$IOS_PLATFORM && cd $TRAVIS_BUILD_DIR/test/build_$IOS_PLATFORM
    cmake -DCMAKE_TOOLCHAIN_FILE=$TRAVIS_BUILD_DIR/test/bazel.cmake/third-party/ios-cmake/toolchain/iOS.cmake \
          -DIOS_PLATFORM=$IOS_PLATFORM \
          ..
    make "-j$(sysctl -n hw.ncpu)" VERBOSE=1
fi