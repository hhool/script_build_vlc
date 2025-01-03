# Description: Dockerfile for building VLC for Android
# Author: hhool based on the work of the VideoLAN team
# Date: 2025-01-01
# Version: 1.0.0
# Usage: docker build -t vlc-android-build . && docker run -it vlc-android-build
# Note: This Dockerfile is based on the work of the VideoLAN team, and it is
# used to build VLC for Android.
# vlc-android git repository: https://code.videolan.org/videolan/vlc-android
# git address: https://code.videolan.org/videolan/vlc-android.git@5821fab251c06b78241037788f1a3fc86aa8d985
# Reference: https://code.videolan.org/videolan/docker-images/-/blob/master/vlc-debian-android-3.0/Dockerfile?ref_type=heads
# Reference: https://code.videolan.org/videolan/vlc-android/-/blob/master/CONTRIBUTING.md
# Reference: https://code.videolan.org/videolan/vlc-android/-/blob/master/README.md
# Reference: https://code.videolan.org/videolan/vlc-android/-/blob/master/README.md#building-vlc-for-android

FROM debian:bookworm-20230522-slim

LABEL maintainer="hhool <seaman.player@gmail.com>"

ENV IMAGE_DATE=202306200801

ENV ANDROID_NDK="/sdk/android-ndk" \
    ANDROID_SDK="/sdk/android-sdk-linux"

# If someone wants to use VideoLAN docker images on a local machine and does
# not want to be disturbed by the videolan user, we should not take an uid/gid
# in the user range of main distributions, which means:
# - Debian based: <1000
# - RPM based: <500 (CentOS, RedHat, etc.)
ARG VIDEOLAN_CI_UID=499

ARG CORES=8

ENV PATH=/sdk/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/:/opt/tools/bin:$PATH

RUN groupadd --gid ${VIDEOLAN_CI_UID} videolan && \
    useradd --uid ${VIDEOLAN_CI_UID} --gid videolan --create-home --shell /bin/bash videolan && \
    echo "videolan:videolan" | chpasswd && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
    apt-get install --no-install-suggests --no-install-recommends -y \
    openjdk-17-jdk-headless ca-certificates autoconf m4 automake ant autopoint bison \
    flex build-essential libtool libtool-bin patch pkg-config cmake meson \
    git yasm ragel g++ gettext ninja-build \
    wget expect unzip python3 \
    locales libltdl-dev curl nasm && \
    dpkg-reconfigure locales && \
    apt-get clean -y && rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    echo "export ANDROID_NDK=${ANDROID_NDK}" >> /etc/profile.d/vlc_env.sh && \
    echo "export ANDROID_SDK=${ANDROID_SDK}" >> /etc/profile.d/vlc_env.sh && \
    mkdir sdk && cd sdk && \
    ANDROID_NDK_VERSION=21e && \
    ANDROID_NDK_SHA256=ad7ce5467e18d40050dc51b8e7affc3e635c85bd8c59be62de32352328ed467e && \
    wget -q https://dl.google.com/android/repository/android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip && \
    echo $ANDROID_NDK_SHA256 android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip | sha256sum -c && \
    unzip android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip && \
    rm -f android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.zip && \
    ln -s android-ndk-r$ANDROID_NDK_VERSION android-ndk && \
    mkdir android-sdk-linux && \
    cd android-sdk-linux && \
    mkdir "licenses" && \
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "licenses/android-sdk-license" && \
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" >> "licenses/android-sdk-license" && \
    SDK_TOOLS_FILENAME=commandlinetools-linux-9477386_latest.zip && \
    wget -q https://dl.google.com/android/repository/$SDK_TOOLS_FILENAME && \
    SDK_TOOLS_SHA256=bd1aa17c7ef10066949c88dc6c9c8d536be27f992a1f3b5a584f9bd2ba5646a0 && \
    echo $SDK_TOOLS_SHA256 $SDK_TOOLS_FILENAME | sha256sum -c && \
    unzip $SDK_TOOLS_FILENAME && \
    rm -f $SDK_TOOLS_FILENAME && \
    cd / && \
    cd sdk/android-sdk-linux && \
    cmdline-tools/bin/sdkmanager --sdk_root=/sdk/android-sdk-linux/ "build-tools;26.0.1" "platform-tools" "platforms;android-26" && \
    chown -R videolan /sdk

ENV LANG=en_US.UTF-8
USER videolan

# We need to set the user name and email for git to avoid warnings
# when cloning repositories, check env variables GIT_COMMITTER_NAME is set
# or not, if not set, set it to "VLC Android"
# This is needed to avoid warnings when cloning repositories in the build
# process of VLC Android project in the CI pipeline of VideoLAN  (Jenkins)

# check if GIT_COMMITTER_NAME is set or not, if not set, set it to "VLC Android"
RUN if [ -z "$GIT_COMMITTER_NAME" ]; then export GIT_COMMITTER_NAME="VLC Android"; fi
# check if GIT_COMMITTER_EMAIL is set or not, if not set, set it to "buildbot@videolan.org"
RUN if [ -z "$GIT_COMMITTER_EMAIL" ]; then export GIT_COMMITTER_EMAIL="buildbot@videolan.org"; fi
RUN git config --global user.name "VLC Android" && \
    git config --global user.email buildbot@videolan.org
